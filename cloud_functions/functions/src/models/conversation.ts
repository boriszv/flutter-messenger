export class Conversation {
  users: ConversationUser[] = [];
  userIds: string[] = [];
}

export class ConversationUser {
  userId: string = '';
  userName: string = '';
}