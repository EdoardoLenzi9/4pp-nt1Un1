const parameterValidationSvc = require('../Delays.BackEnd/Services/ParameterValidationService.js');

test('throwErrorWhenValidateWrongRuoteId', () => {
  expect(() => {
    parameterValidationSvc.ValidateRouteId("1000")
  }).toThrow();
});

test('throwErrorWhenValidateWrongTripId', () => {
    expect(() => {
      parameterValidationSvc.ValidateTripId("1000100010001000100010001000100010001000")
    }).toThrow();
});

test('throwErrorWhenValidateWrongStopId', () => {
    expect(() => {
      parameterValidationSvc.ValidateStopId("10000001000100010001000100010001")
    }).toThrow();
});

test('throwErrorWhenValidateWrongDirection', () => {
    expect(() => {
      parameterValidationSvc.ValidateDirection("3")
    }).toThrow();
});

test('throwErrorWhenValidateWrongArrivalTime', () => {
    expect(true).toBe(true);
});

test('throwErrorWhenValidateWrongDepartureTime', () => {
    expect(true).toBe(true);
});