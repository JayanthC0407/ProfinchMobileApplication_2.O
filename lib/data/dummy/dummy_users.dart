import 'package:profinch_mobile_application/data/models/user_model.dart';

class DummyUsers {
  DummyUsers._();

  static final List<UserModel> allUsers = [

    UserModel(
      id: 'USR001',
      primaryAccountId: 'ACC001',
      username: 'Arjun Sharma',
      email: 'arjun.sharma@email.com',
      password: '123456',
      phoneNumber: '9876543210',
      panNumber: 'ABCPS1234F',
      profileImage: '',
      accountNumber: '1234567890',
      createdAt: DateTime(2023, 1, 15),
      isKycVerified: true,
    ),


    UserModel(
      id: 'USR002',
      primaryAccountId: 'ACC004',
      username: 'Priya Nair',
      email: 'priya.nair@email.com',
      password: '123456',
      phoneNumber: '9123456780',
      panNumber: 'BCDPN5678G',
      profileImage: '',
      accountNumber: '9876543210',
      createdAt: DateTime(2023, 3, 20),
      isKycVerified: true,
    ),

    UserModel(
      id: 'USR003',
      primaryAccountId: 'ACC007',
      username: 'Rahul Mehta',
      email: 'rahul.mehta@email.com',
      password: '123456',
      phoneNumber: '9988776655',
      panNumber: 'CDERM9012H',
      profileImage: '',
      accountNumber: '1122334455',
      createdAt: DateTime(2023, 5, 10),
      isKycVerified: false,
    ),
  ];
}