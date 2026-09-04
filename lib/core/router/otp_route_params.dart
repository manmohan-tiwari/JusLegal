class OtpRouteParams {
  const OtpRouteParams({
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  factory OtpRouteParams.fromExtra(Object? extra) {
    if (extra is OtpRouteParams) return extra;
    if (extra is Map) {
      return OtpRouteParams(
        verificationId: extra['verificationId'] as String? ?? '',
        phoneNumber: extra['phoneNumber'] as String? ?? '',
      );
    }
    return const OtpRouteParams(verificationId: '', phoneNumber: '');
  }
}