enum UIState<T> {
    case idle
    case loading
    case success(T)
    case error(String)
}