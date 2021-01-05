import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Message } from './models/message';

const db = admin.firestore();

export const onMessageCreated = functions.firestore
  .document('conversations/{conversationId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const conversationId = context.params.conversationId;
    const body = snapshot.data() as Message;

    await db.runTransaction(async (transaction) => {
      const conversationRef = db.doc(`conversations/${conversationId}`);
      transaction.update(conversationRef, {
        latestMessage: body.messageText,
        latestMessageTimestamp: snapshot.createTime,
        latestMessageSentBy: body.userId
      });
    }); 
  });
