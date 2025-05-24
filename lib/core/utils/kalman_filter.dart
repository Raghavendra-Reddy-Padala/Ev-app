class KalmanFilter {
  double _q = 0.01; // Process noise (reduce for smoother output)
  double _r = 0.1; // Measurement noise
  double _p = 1.0; // Estimation error
  double _k = 0.0; // Kalman gain
  double _x = 0.0; // Value (initialized to 0)

  double update(double measurement) {
    // Prediction update
    _p = _p + _q;

    // Measurement update
    _k = _p / (_p + _r);
    _x = _x + _k * (measurement - _x);
    _p = (1 - _k) * _p;

    return _x;
  }

  void reset() {
    _x = 0.0;
    _p = 1.0;
    _k = 0.0;
  }
}
