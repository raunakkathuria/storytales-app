/// Base class for all use cases.
///
/// This abstract class defines the contract that all use cases must fulfill.
/// It provides a standard way to execute use cases with parameters.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters.
  ///
  /// [params] - The parameters required to execute the use case.
  ///
  /// Returns a value of type [Type] representing the result of the use case.
  Future<Type> call(Params params);
}

/// Class representing no parameters for a use case.
///
/// This class is used when a use case doesn't require any parameters.
class NoParams {
  const NoParams();
}
