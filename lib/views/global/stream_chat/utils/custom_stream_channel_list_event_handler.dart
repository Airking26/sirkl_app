import 'package:sirkl/views/global/stream_chat/stream_chat_flutter.dart';

/// Contains handlers that are called from [StreamChannelListController] for
/// certain [Event]s.
///
/// This class can be mixed in or extended to create custom overrides.
class CustomStreamChannelListEventHandler
    implements StreamChannelListEventHandler {
  /// Function which gets called for the event
  /// [EventType.channelDeleted].
  ///
  /// This event is fired when a channel is deleted.
  ///
  /// By default, this removes the channel from the list of channels.
  void onChannelDeleted(Event event, StreamChannelListController controller) {
    final channels = [...controller.currentItems];

    final updatedChannels = channels
      ..removeWhere(
        (it) => it.cid == (event.cid ?? event.channel?.cid),
      );

    controller.channels = updatedChannels;
  }

  /// Function which gets called for the event
  /// [EventType.channelHidden].
  ///
  /// This event is fired when a channel is hidden.
  ///
  /// By default, this removes the channel from the list of channels.
  void onChannelHidden(Event event, StreamChannelListController controller) {
    onChannelDeleted(event, controller);
  }

  /// Function which gets called for the event
  /// [EventType.channelTruncated].
  ///
  /// This event is fired when a channel is truncated.
  ///
  /// By default, this refreshes the whole channel list.
  void onChannelTruncated(Event event, StreamChannelListController controller) {
    controller.refresh();
  }

  /// Function which gets called for the event
  /// [EventType.channelUpdated].
  ///
  /// This event is fired when a channel is updated.
  ///
  /// By default, this updates the channel received in the event.
  // ignore: no-empty-block
  void onChannelUpdated(Event event, StreamChannelListController controller) {}

  /// Function which gets called for the event
  /// [EventType.channelVisible].
  ///
  /// This event is fired when a channel is made visible.
  ///
  /// By default, this adds the channel to the list of channels.
  void onChannelVisible(
      final Event event, final StreamChannelListController controller) async {
    if (event.cid == null) return;

    final cidFilter = Filter.equal('cid', event.cid!);
    final filter = controller.filter == null
        ? cidFilter
        : Filter.and([controller.filter!, cidFilter]);
    await for (final channels
        in controller.client.queryChannels(filter: filter)) {
      final channel = channels.firstOrNull;
      if (channel == null) return;

      controller.channels = [
        channel,
        ...controller.currentItems.where((final cc) => cc.cid != channel.cid),
      ];
    }
  }

  /// Function which gets called for the event
  /// [EventType.connectionRecovered].
  ///
  /// This event is fired when the client web-socket connection recovers.
  ///
  /// By default, this refreshes the whole channel list.
  void onConnectionRecovered(
    Event event,
    StreamChannelListController controller,
  ) {
    controller.refresh();
  }

  /// Function which gets called for the event [EventType.messageNew].
  ///
  /// This event is fired when a new message is created in one of the channels
  /// we are currently watching.
  ///
  /// By default, this moves the channel to the top of the list.
  void onMessageNew(Event event, StreamChannelListController controller) async {
    final channelCid = event.cid;
    if (channelCid == null) return;

    final channels = [...controller.currentItems];

    final channelIndex = channels.indexWhere((it) => it.cid == channelCid);
    if (channelIndex < 0) {
      // If the channel is not in the list, It might be hidden.
      // So, we just refresh the list.
      await controller.refresh(resetValue: false);
      return;
    }

    final channel = channels.removeAt(channelIndex);
    channels.insert(0, channel);

    controller.channels = [...channels];
  }

  /// Function which gets called for the event
  /// [EventType.notificationAddedToChannel].
  ///
  /// This event is fired when a channel is added which we are not watching.
  ///
  /// By default, this adds the channel and moves it to the top of list.
  void onNotificationAddedToChannel(
    Event event,
    StreamChannelListController controller,
  ) {
    onChannelVisible(event, controller);
  }

  /// Function which gets called for the event
  /// [EventType.notificationMessageNew].
  ///
  /// This event is fired when a new message is created in a channel
  /// which we are not currently watching.
  ///
  /// By default, this adds the channel and moves it to the top of list.
  void onNotificationMessageNew(
    Event event,
    StreamChannelListController controller,
  ) {
    onChannelVisible(event, controller);
  }

  /// Function which gets called for the event
  /// [EventType.notificationRemovedFromChannel].
  ///
  /// This event is fired when a user is removed from a channel which we are
  /// not currently watching.
  ///
  /// By default, this removes the event channel from the list.
  void onNotificationRemovedFromChannel(
    Event event,
    StreamChannelListController controller,
  ) {
    final channels = [...controller.currentItems];
    final updatedChannels =
        channels.where((it) => it.cid != event.channel?.cid);
    final listChanged = channels.length != updatedChannels.length;

    if (!listChanged) return;

    controller.channels = [...updatedChannels];
  }

  /// Function which gets called for the event
  /// 'user.presence.changed' and [EventType.userUpdated].
  ///
  /// This event is fired when a user's presence changes or gets updated.
  ///
  /// By default, this updates the channel member with the event user.
  void onUserPresenceChanged(
    Event event,
    StreamChannelListController controller,
  ) {
    final user = event.user;
    if (user == null) return;

    final channels = [...controller.currentItems];

    final updatedChannels = channels.map((channel) {
      final members = [...channel.state!.members];
      final memberIndex = members.indexWhere(
        (it) => user.id == (it.userId ?? it.user?.id),
      );

      if (memberIndex < 0) return channel;

      members[memberIndex] = members[memberIndex].copyWith(user: user);
      final updatedState = ChannelState(members: [...members]);
      channel.state!.updateChannelState(updatedState);

      return channel;
    });

    controller.channels = [...updatedChannels];
  }
}