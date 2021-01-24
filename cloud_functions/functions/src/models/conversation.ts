export class Conversation {
  users: ConversationUser[] = [];
  userIds: string[] = [];
  userIdsHash?: string = '';
  latestMessage?: string | undefined;
  latestMessageId?: string | undefined;
  latestMessageTimestamp?: FirebaseFirestore.Timestamp | undefined;
  latestMessageSentBy?: string | undefined;
  seen: { [userId: string]: string } = {};
}

export class ConversationWithId extends Conversation {
  uid: string = '';

  static fromBase(uid: string, user: Conversation): ConversationWithId {
    return { uid, ...user };
  }
}

export class ConversationUser {
  userId: string = '';
  userName: string = '';
  imageUrl: string = '';
}