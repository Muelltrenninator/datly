import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:retry/retry.dart';

import 'database/database.dart';
import 'email/email.dart';
import 'helpers.dart';
import 'server.dart';

late final OpenAIClient _moderationClient;
late final bool moderationEnabled;
void initializeModeration() {
  if (!env.isDefined("OPENAI_API_KEY")) {
    t.error(
      "OPENAI_API_KEY is not defined in the environment variables. Moderation features will be disabled.",
    );
    moderationEnabled = false;
    return;
  }
  moderationEnabled = true;

  _moderationClient = OpenAIClient(
    // config: OpenAIConfig(authProvider: ApiKeyProvider(env["OPENAI_API_KEY"]!)),
    apiKey: env["OPENAI_API_KEY"]!,
  );

  (db.submissions.select()..where((s) => s.moderated.equals(false))).get().then(
    (submissions) {
      for (final submission in submissions) {
        queueModeration(submission);
      }
    },
  );
}

final _moderationQueue = <({Submission submission, int failedIterations})>[];
void queueModeration(Submission submission) {
  if (!moderationEnabled) return;
  _moderationQueue.add((submission: submission, failedIterations: 0));
  _processLoop();
}

var _processLoopLock = false;
void _processLoop() async {
  if (_processLoopLock) return;
  _processLoopLock = true;

  while (true) {
    if (_moderationQueue.isEmpty) {
      _processLoopLock = false;
      break;
    }

    final submission = _moderationQueue.removeAt(0);
    try {
      if (submission.submission.assetId == null ||
          submission.submission.assetMimeType == null) {
        await (db.update(db.submissions)
              ..where((s) => s.id.equals(submission.submission.id)))
            .write(SubmissionsCompanion(moderated: const Value(true)));
        continue;
      }
      await RetryOptions(maxAttempts: 3).retry(() async {
        final data =
            "data:${submission.submission.assetMimeType};base64,${base64Encode(await assetFile(submission.submission.assetId!, submission.submission.assetMimeType!).readAsBytes())}";
        final response = await _moderationClient.createModeration(
          request: CreateModerationRequest(
            model: ModerationModel.model(ModerationModels.omniModerationLatest),
            input: ModerationInput.listModerationInputObject([
              ModerationInputObjectImageUrl(
                imageUrl: ModerationInputObjectImageUrlImageUrl(url: data),
              ),
            ]),
          ),
        );

        final affectedCategories = response.results.first.categories
            .toJson()
            .entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();
        if (affectedCategories.isNotEmpty) {
          if (affectedCategories.contains("sexual") ||
              affectedCategories.contains("sexual/minors")) {
            final user =
                await (db.users.select()..where(
                      (u) => u.username.equals(submission.submission.user),
                    ))
                    .getSingle();
            final reason = Intl.withLocale(
              user.locale,
              () => emailAccountDisabledReasonModeration(),
            );
            final admin =
                (await (db.users.select()
                          ..where((u) => u.role.equals(UserRole.admin.name)))
                        .get())
                    .first;
            await (db.update(db.users)
                  ..where((u) => u.username.equals(user.username)))
                .write(UsersCompanion(disabled: Value(reason.trim())));

            queueEmail(
              EmailMessagesTemplates.accountDisabled(
                user: user,
                reason: reason.trim(),
              ).stylized(),
            );
            queueEmail(
              EmailMessagesTemplates.accountDisabledModerationAdmin(
                user: admin,
                submission: submission.submission,
                categories: affectedCategories.join(", "),
              ).stylized(priority: MessagePriority.highest),
            );
          } else {
            final asset = assetFile(
              submission.submission.assetId!,
              submission.submission.assetMimeType!,
            );
            if (await asset.exists()) await asset.delete();

            await (db.update(
              db.submissions,
            )..where((s) => s.id.equals(submission.submission.id))).write(
              SubmissionsCompanion(
                status: Value(SubmissionStatus.censored),
                assetId: const Value(null),
                assetMimeType: const Value(null),
              ),
            );
          }
        }

        await (db.update(db.submissions)
              ..where((s) => s.id.equals(submission.submission.id)))
            .write(SubmissionsCompanion(moderated: const Value(true)));
      }, onRetry: (e) => t.warn("Failed to moderate, retrying", error: e));
    } catch (e, s) {
      if (submission.failedIterations < 1) {
        t.error(
          "Failed to moderate after multiple attempts.",
          error: e,
          stack: s,
        );

        // add to end of the queue to try again later
        _moderationQueue.add((
          submission: submission.submission,
          failedIterations: submission.failedIterations + 1,
        ));
      } else {
        // failed, [last + current = 2] * 3 attempts in total
        t.error(
          "Giving up on moderation after multiple failed attempts",
          description:
              "Submission ID: ${submission.submission.id}, User: ${submission.submission.user}",
          error: e,
          stack: s,
        );
      }
    }

    // rate limit/spam prevention: waiting a bit before sending the next
    await Future.delayed(
      Duration(
        seconds:
            _moderationQueue.length == 1 &&
                _moderationQueue.first.submission == submission.submission
            ? 30
            : 1,
      ),
    );
  }
}
