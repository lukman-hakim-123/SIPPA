import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/anekdot/anekdot_card.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/error.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/anekdot.dart';

class AnekdotList extends ConsumerWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AnekdotList());

  const AnekdotList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserAccountProvider).value!.$id;
    return ref.watch(getAnekdotByUserIdProvider(userId)).when(
          data: (tweets) {
            return ref.watch(getLatestAnekdotProvider).when(
                  data: (data) {
                    if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.anekdotCollection}.documents.*.create',
                    )) {
                      if (data.payload['uid'] == userId) {
                        tweets.add(AnekdotModel.fromMap(data.payload));
                      }
                    } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.anekdotCollection}.documents.*.update',
                    )) {
                      // get id of original tweet
                      final startingPoint =
                          data.events[0].lastIndexOf('documents.');
                      final endPoint = data.events[0].lastIndexOf('.update');
                      final tweetId = data.events[0]
                          .substring(startingPoint + 10, endPoint);

                      var tweet = tweets
                          .where((element) => element.id == tweetId)
                          .first;

                      final tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweetId);

                      tweet = AnekdotModel.fromMap(data.payload);
                      if (data.payload['uid'] == userId) {
                        tweets.insert(tweetIndex, tweet);
                      }
                    } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.anekdotCollection}.documents.*.delete',
                    )) {
                      tweets.remove(AnekdotModel.fromMap(data.payload));
                    }
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return AnekdotCard(anekdot: tweet);
                      },
                    );
                  },
                  error: (error, stackTrace) => ErrorText(
                    error: error.toString(),
                  ),
                  loading: () {
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        return AnekdotCard(anekdot: tweet);
                      },
                    );
                  },
                );
          },
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
