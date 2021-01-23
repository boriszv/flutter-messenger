import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Message } from '../models/message';
import { Conversation } from '../models/conversation';

const db = admin.firestore();

export const onMessageCreated = functions.firestore
  .document('conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const conversationId = context.params.conversationId;
    const messageId = context.params.messageId;

    const body = snapshot.data() as Message;

    const conversationPatch: Partial<Conversation> = {
      latestMessage: body.messageText,
      latestMessageTimestamp: snapshot.createTime,
      latestMessageSentBy: body.userId
    };

    if (!body.messageText && body.imageUrl) {
      conversationPatch.latestMessage = 'Image';
    }

    const messageToPatch: Partial<Message> = {
      createTime: snapshot.createTime
    };

    await Promise.all([
      db.doc(`conversations/${conversationId}`).update(conversationPatch),
      db.doc(`conversations/${conversationId}/messages/${messageId}`).update(messageToPatch),
    ]);
  });
