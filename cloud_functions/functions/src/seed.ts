import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

export const seedData = functions.https.onRequest(async (req, res) => {
  await seedUsers();

  res.send();
});


const seedUsers = async () => {
  const ids = await Promise.all([
    createUser('Mike Jones', '+1 203-773-2516'),
    createUser('Dwayne Carter', '+1 412-923-1733'),
  ]);

  await seedMessages(ids);
};

const seedMessages = async (ids: string[]) => {
  await db.collection('conversations')
    .add({
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
