import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as faker from 'faker';

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

export const seedData = functions.https.onRequest(async (req, res) => {
  const userIds = await seedUsers();
  const conversationIds = await seedConversations(userIds);
  await seedMessages(userIds, conversationIds);

  res.send();
});


const seedUsers = async () => {
  return await Promise.all([
    createUser('Mike Jones', '+1 203-773-2516'),
    createUser('Dwayne Carter', '+1 412-923-1733'),
  ]);
};


const seedConversations = async (ids: string[]) : Promise<string[]> => {
  const reference = db.collection('conversations').doc();
  await reference.set({
    users: [
      {
        userId: ids[0],
        userName: 'Mike Jones',
      },
      {
        userId: ids[1],
        userName: 'Dwayne Carter',
      }
    ],
    userIds: [...ids],
  });

  return [reference.id];
};


const seedMessages = async (userIds: string[], conversationIds: string[]) : Promise<string[]> => {
  const messageIds = [];

  for (const userId of userIds) {
    const reference = db.collection(`conversations/${conversationIds[0]}/messages`);
    await reference.add({
      messageText: faker.lorem.text(),
      imageUrl: faker.image.imageUrl(),
      sent: admin.database.ServerValue.TIMESTAMP,
      userId: userId
    });
    messageIds.push(reference.id);
  }

  return messageIds;
};


const createUser = async (name: string, phoneNumber: string) : Promise<string> => {
  const createdUser = await auth.createUser({
    phoneNumber: phoneNumber,
    displayName: name,
    password: 'pass123'
  });

  await db.collection('users')
    .doc(createdUser.uid)
    .set({
      phoneNumber: phoneNumber,
      name: name,
      bio: 'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et.'
    });

  return createdUser.uid;
};
