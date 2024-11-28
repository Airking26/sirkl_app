enum GamificationCycleType { daily, weekly }

enum GamificationDailyTasks {
  dailyCheckIn,
  communityInteraction,
  connectWithNewUser,
  upVotePost,
  shareOnX
}

extension GamificationDailyTasksExtension on GamificationDailyTasks {
  String get displayName {
    switch (this) {
      case GamificationDailyTasks.dailyCheckIn:
        return 'Daily Check-in';
      case GamificationDailyTasks.communityInteraction:
        return 'Community Interaction';
      case GamificationDailyTasks.connectWithNewUser:
        return 'Connect with a New User';
      case GamificationDailyTasks.upVotePost:
        return 'Upvote a Post';
      case GamificationDailyTasks.shareOnX:
        return 'Share SIRKL profile';
    }
  }
}
