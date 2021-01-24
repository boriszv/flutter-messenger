import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Conversation, ConversationUser } from '../models/conversation';
import { User } from '../models/user';

const db = admin.firestore();

export const onConversationCreated = functions.firestore
  .document('conversations/{conversationId}')
  .onCreate(async (snapshot, context) => {
    const body = snapshot.data() as Conversation;

    const users = await Promise.all(body.userIds.map(async id => {
      const x = await db.doc(`users/${id}`).get();
      const data = (x.data() as User);
      const user: ConversationUser = {
        userId: x.id,
        userName: data.name,
        imageUrl: data.imageUrl
      };
      return user;
    }));

    body.userIds.sort((a, b) => a.localeCompare(b))

    const conversationToUpdate: Partial<Conversation> = {
      userIdsHash: body.userIds.join(''),
      users: users
    };
    await snapshot.ref.update(conversationToUpdate);
  });
