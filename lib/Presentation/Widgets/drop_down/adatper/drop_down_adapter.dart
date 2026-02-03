abstract class ModelAdapter<T, R> {
  R convert(T input);

  List<R> convertList(List<T> inputList) {
    return inputList.map((item) => convert(item)).toList();
  }
}
