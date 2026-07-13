import '../models/beneficiary_model.dart';

class DummyBeneficiaries {
  DummyBeneficiaries._();

  static final List<BeneficiaryModel> beneficiaries = [

    BeneficiaryModel(
      id: 'BEN001',
      userId: 'USR002',
      nickname: 'Priya Nair',
      beneficiaryType: 'PBI',
      accountNumber: '010493142944',
      bankName: 'ProFinch Bank',
      ifscCode: 'PRFN0000017',
      isVerified: true,
      addedAt: DateTime(2000), // pre-existing — cooling never applies
    ),

    BeneficiaryModel(
      id: 'BEN002',
      userId: 'USR001',
      nickname: 'Arjun Sharma',
      beneficiaryType: 'LOCAL',
      accountNumber: '123456789012',
      bankName: 'HDFC Bank',
      ifscCode: 'HDFC0001234',
      isVerified: true,
      addedAt: DateTime(2000), // pre-existing — cooling never applies
    ),
  ];
}