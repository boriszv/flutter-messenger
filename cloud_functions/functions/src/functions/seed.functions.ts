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

export const deleteAllAuthUsers = functions.https.onRequest(async (req, res) => {
  const users = await auth.listUsers();
  const promises = users.users.map(x => auth.deleteUser(x.uid));
  await Promise.all(promises);
  res.send({ success: true });
});

const seedUsers = async () => {
  const promises = [createUser('Boris Zivkovic', 'boris@example.com')];

  let userCount = 15;
  while (userCount--) {
    const [firstName, lastName] = [faker.name.firstName(), faker.name.lastName()];
    promises.push(createUser(`${firstName} ${lastName}`, faker.internet.email(firstName, lastName)));
  }

  return await Promise.all(promises);
};

const seedConversationsAndMessages = async (users: UserWithId[]): Promise<ConversationWithId[]> => {
  const mainUser = users[0]; // our user - Boris
  users.shift();

  const conversationsToReturn: ConversationWithId[] = [];
  const conversationPromises = [];
  const messagePromises = [];

  for (const user of users) {
    const conversationToInsert: Conversation = {
      users: [
        { userId: mainUser.uid, userName: mainUser.name, imageUrl: mainUser.imageUrl },
        { userId: user.uid, userName: user.name, imageUrl: user.imageUrl }
      ],
      userIds: [mainUser.uid, user.uid],
      seen: {}
    };

    const conversationReference = db.collection('conversations').doc();
    conversationPromises.push(conversationReference.set(conversationToInsert));
    conversationsToReturn.push(ConversationWithId.fromBase(conversationReference.id, conversationToInsert));
  }

  await Promise.all(conversationPromises);

  for (const conversation of conversationsToReturn) {
    const otherUserId = conversation.userIds.find(x => x !== mainUser.uid);
    if (!otherUserId) continue;

    let messageCount = randomInt(15, 80);
    while (messageCount--) {
      const messageToInsert: Message = {
        userId: randomBool() ? mainUser.uid : otherUserId,
        imageUrl: randomInt(1, 21) > 15 ? faker.image.imageUrl() : '',
        messageText: faker.lorem.sentence(randomInt(5, 22)),
      };

      const messageReference = db.collection(`conversations/${conversation.uid}/messages`).doc();
      messagePromises.push(messageReference.set(messageToInsert));
    }
  }

  await Promise.all(messagePromises);
  return conversationsToReturn;
};

const createUser = async (name: string, email: string): Promise<UserWithId> => {
  const authUser = await auth.createUser({
    email: email,
    displayName: name,
    password: 'pass123'
  });

  const images = [faker.image.abstract(150, 150), faker.image.animals(150, 150), faker.image.business(150, 150), faker.image.cats(150, 150), faker.image.city(150, 150), faker.image.food(150, 150), faker.image.nightlife(150, 150), faker.image.fashion(150, 150), faker.image.people(150, 150), faker.image.nature(150, 150), faker.image.sports(150, 150), faker.image.technics(150, 150), faker.image.transport(150, 150)];

  const userToInsert: User = {
    email: email,
    name: name,
    imageUrl: images[Math.floor(Math.random() * 10)],
    bio: faker.lorem.sentences(3)
  };

  await db.collection('users').doc(authUser.uid).set(userToInsert);
  return UserWithId.fromBase(authUser.uid, userToInsert);
};

const randomBool = () => Math.floor(Math.random() * 2);
const randomInt = (min: number = 0, max: number = 100) => Math.floor(Math.random() * (max - min) + min);
