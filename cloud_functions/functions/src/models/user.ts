export class User {
  phoneNumber: string = '';
  name: string = '';
  bio: string = '';
  imageUrl: string = '';
}

export class UserWithId extends User {
  uid: string = '';

  static fromBase(uid: string, user: User): UserWithId {
    return { uid, ...user };
  }
}
