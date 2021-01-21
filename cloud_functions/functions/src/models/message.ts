import { firestore } from "firebase-admin";

export class Message {
  messageText: string = '';
  imageUrl: string = '';
  userId: string = '';
  createTime?: firestore.Timestamp = undefined;
}
