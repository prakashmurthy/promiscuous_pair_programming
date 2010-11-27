function temporarilySetting(values, func, context) {
  var oldvalues = [];
  for (var i=0; i<values.length; i++) {
    var _ = values[i], k = _[0], oldvalue = k[0][k[1]], newvalue = _[1];
    oldvalues[i] = oldvalue;
    k[0][k[1]] = newvalue;
  }
  func.call(context);
  for (var i=0; i<values.length; i++) {
    var _ = values[i], k = _[0], oldvalue = k[0][k[1]], newvalue = _[1];
    k[0][k[1]] = oldvalue;
  }
}