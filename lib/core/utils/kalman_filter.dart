class KalmanFilter {
  double q = 0.01;
  double r = 0.1;
  double p = 1.0;
  double k = 0.0;
  double x = 0.0;

  double update(double measurement) {
    p = p + q;
    k = p / (p + r);
    x = x + k * (measurement - x);
    p = (1 - k) * p;

    return x;
  }
}
