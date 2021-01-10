import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as faker from 'faker';
import { User, UserWithId } from '../models/user';
import { Message } from '../models/message';
import { Conversation, ConversationWithId } from '../models/conversation';

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

export const seedData = functions.https.onRequest(async (req, res) => {
  if ((await db.collection('users').get()).docs.length > 0) {
    res.send({ success: false, error: 'There is already data in the database' });
    return;
  }

  const users = await seedUsers();
  await seedConversationsAndMessages(users);

  res.send({ success: true });
});


const seedUsers = async () => {
  const promises = [createUser('Boris Zivkovic', '+1 202-555-0155')];

  let userCount = 15;
  while (userCount--) {
    promises.push(createUser(`${faker.name.firstName()} ${faker.name.lastName()}`, faker.phone.phoneNumber('+1 !##-!##-####')));
  }

  return await Promise.all(promises);
};


const seedConversationsAndMessages = async (users: UserWithId[]): Promise<ConversationWithId[]> => {
  const mainUser = users[0]; // our user - Boris
  users.shift();

  const conversationsToReturn: ConversationWithId[] = [];

  for (const user of users) {
    const conversationToInsert: Conversation = {
      users: [
        {
          userId: mainUser.uid,
          userName: mainUser.name,
          imageUrl: mainUser.imageUrl,
        },
        {
          userId: user.uid,
          userName: user.name,
          imageUrl: user.imageUrl,
        }
      ],
      userIds: [mainUser.uid, user.uid],
    };

    const conversationReference = db.collection('conversations').doc();
    await conversationReference.set(conversationToInsert);

    conversationsToReturn.push(ConversationWithId.fromBase(conversationReference.id, conversationToInsert));

    // Seed messages for created conversation

    let messageCount = randomInt(15, 80);
    while (messageCount--) {
      const messageToInsert: Message = {
        userId: randomBool() ? mainUser.uid : user.uid,
        imageUrl: randomInt(1, 21) > 15 ? faker.image.imageUrl() : '',
        messageText: faker.lorem.sentence(randomInt(5, 22)),
      };

      const messageReference = db.collection(`conversations/${conversationReference.id}/messages`).doc();
      await messageReference.set(messageToInsert)
    }
  }

  return conversationsToReturn;
};

const createUser = async (name: string, phoneNumber: string): Promise<UserWithId> => {
  const authUser = await auth.createUser({
    phoneNumber: phoneNumber,
    displayName: name,
    password: 'pass123'
  });

  const userToInsert: User = {
    phoneNumber: phoneNumber,
    name: name,
    imageUrl: faker.image.imageUrl(),
    bio: faker.lorem.sentences(3)
  };

  await db.collection('users').doc(authUser.uid).set(userToInsert);
  return UserWithId.fromBase(authUser.uid, userToInsert);
};

const randomBool = () => Math.floor(Math.random() * 2);
const randomInt = (min: number = 0, max: number = 100) => Math.floor(Math.random() * (max - min) + min);
