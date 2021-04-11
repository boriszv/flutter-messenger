import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { Conversation } from '../models/conversation';
import { User } from '../models/user';

const db = admin.firestore();

export const onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snapshot, context) => {
    const body = snapshot.data() as User;

    const userToUpdate: Partial<User> = {
      email: body.email?.replace(' ', '')
    };
    await snapshot.ref.update(userToUpdate);
  });


export const onUserUpdated = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (snapshot, context) => {
    const id = context.params.userId;
    const bodyBefore = snapshot.before.data() as User;
    const body = snapshot.after.data() as User;

    if (body.name === bodyBefore.name) {
      return;
    }

    const conversationsQuery = await db.collection('conversations')
      .where('userIds', 'array-contains', id)
      .get();

    const promises = [];
    for (const document of conversationsQuery.docs) {
      const conversation = document.data() as Conversation;

      const userToUpdate = conversation.users.find(x => x.userId === id);
      if (!userToUpdate) continue;

      userToUpdate.userName = body.name;
      promises.push(document.ref.update(conversation));
    }

    await Promise.all(promises);
  });
