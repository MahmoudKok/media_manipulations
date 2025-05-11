// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProcessResult<T> {
  final bool isSuccess;
  final String? message;
  final T? data;

  ProcessResult({
    required this.isSuccess,
    this.message,
    this.data,
  });

  factory ProcessResult.success({String? message, T? data}) {
    return ProcessResult<T>(isSuccess: true, message: message, data: data);
  }

  factory ProcessResult.failure({String? message, T? data}) {
    return ProcessResult<T>(isSuccess: false, message: message, data: data);
  }

  ProcessResult<T> copyWith({
    bool? isSuccess,
    String? message,
    T? data,
  }) {
    return ProcessResult<T>(
      isSuccess: isSuccess ?? this.isSuccess,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  String toString() =>
      'ProcessResult(isSuccess: $isSuccess, message: $message, data: $data)';
}
