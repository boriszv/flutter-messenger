export class Conversation {
  users: ConversationUser[] = [];
  userIds: string[] = [];
  latestMessage?: string | undefined;
  latestMessageTimestamp?: FirebaseFirestore.Timestamp | undefined;
  latestMessageSentBy?: string | undefined;
}

export class ConversationUser {
  userId: string = '';
  userName: string = '';
}