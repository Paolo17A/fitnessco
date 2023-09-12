import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

bool isLeftHandAboveHead(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHand = pose.landmarks[PoseLandmarkType.leftWrist];
  PoseLandmark? head = pose.landmarks[PoseLandmarkType.nose];

  if (leftHand != null && head != null) {
    double leftHandToHeadDistance = leftHand.y - head.y;

    // Define a threshold distance to determine if the hand is above the head
    double aboveHeadThreshold = -0.1; // Adjust this value as needed

    return leftHandToHeadDistance < aboveHeadThreshold;
  }

  return false;
}

bool isRightHandAboveHead(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? rightHand = pose.landmarks[PoseLandmarkType.rightWrist];
  PoseLandmark? head = pose.landmarks[PoseLandmarkType.nose];

  if (rightHand != null && head != null) {
    double rightHandToHeadDistance = rightHand.y - head.y;

    // Define a threshold distance to determine if the hand is above the head
    double aboveHeadThreshold = -0.1; // Adjust this value as needed

    return rightHandToHeadDistance < aboveHeadThreshold;
  }

  return false;
}

bool isLeftHandBelowHip(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHand = pose.landmarks[PoseLandmarkType.leftWrist];
  PoseLandmark? hip = pose.landmarks[PoseLandmarkType.leftHip];

  if (leftHand != null && hip != null) {
    double leftHandToHipDistance = leftHand.y - hip.y;

    // Define a threshold distance to determine if the hand is below the hip
    double belowHipThreshold = 0.1; // Adjust this value as needed

    return leftHandToHipDistance > belowHipThreshold;
  }

  return false;
}

//ABS
//==========================================================================================================================
bool isStartingSitUpPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
  PoseLandmark? rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

  if (leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftShoulder == null ||
      rightShoulder == null ||
      leftAnkle == null ||
      rightAnkle == null) {
    return false;
  }
  // Process position of shoulders and knees
  double leftThighLength = calculateDistance(leftKnee, leftHip);
  double leftThighThreshold = leftThighLength / 3;
  double rightThighLength = calculateDistance(rightKnee, rightHip);
  double rightThighThreshold = rightThighLength / 3;

  bool shouldersBelowThighMidpoint =
      leftShoulder.y <= leftHip.y + leftThighThreshold &&
          rightShoulder.y <= rightHip.y + rightThighThreshold;

  // Process Angles formed by hips
  double leftHipAngle = getAngle(leftShoulder, leftHip, leftAnkle);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightAnkle);
  double angleThreshold = 150;

  bool isLyingDown =
      leftHipAngle > angleThreshold && rightHipAngle > angleThreshold;

  return isLyingDown && shouldersBelowThighMidpoint;
}

bool isFinishedSitUpPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

  if (leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftShoulder == null ||
      rightShoulder == null) {
    return false;
  }
  // Process Angles formed by hips
  double leftHipAngle = getAngle(leftShoulder, leftHip, leftKnee);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightKnee);
  double angleThreshold = 90;

  //Process angle formed by hips
  bool hipsFormingAcuteAngle =
      leftHipAngle <= angleThreshold && rightHipAngle <= angleThreshold;

  // Process position of shoulders and knees
  bool shouldersAboveKnees =
      leftShoulder.y >= leftKnee.y && rightShoulder.y >= rightKnee.y;

  return hipsFormingAcuteAngle && shouldersAboveKnees;
}

bool isStartingCrunchPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftEye = pose.landmarks[PoseLandmarkType.leftEye];
  PoseLandmark? rightEye = pose.landmarks[PoseLandmarkType.rightEye];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

  if (leftHip == null ||
      rightHip == null ||
      leftShoulder == null ||
      rightShoulder == null ||
      leftEye == null ||
      rightEye == null ||
      leftKnee == null ||
      rightKnee == null) {
    return false;
  }

  double leftThighLength = calculateDistance(leftHip, leftKnee);
  double leftThighThreshold = leftHip.y - ((leftThighLength / 3));

  double rightThighLength = calculateDistance(rightHip, rightKnee);
  double rightThighThreshold = rightHip.y - ((rightThighLength / 3));

  bool eyeLevelWithMidPoints =
      leftThighThreshold <= leftEye.y && rightThighThreshold <= rightEye.y;

  return eyeLevelWithMidPoints;
}

bool isFinishedCrunchPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftEye = pose.landmarks[PoseLandmarkType.leftEye];
  PoseLandmark? rightEye = pose.landmarks[PoseLandmarkType.rightEye];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

  if (leftHip == null ||
      rightHip == null ||
      leftEye == null ||
      rightEye == null ||
      leftShoulder == null ||
      rightShoulder == null ||
      leftKnee == null ||
      rightKnee == null) {
    return false;
  }

  double leftThighLength = calculateDistance(leftHip, leftKnee);
  double leftThighThreshold = leftHip.y - (2 * (leftThighLength / 3));

  double rightThighLength = calculateDistance(rightHip, rightKnee);
  double rightThighThreshold = rightHip.y - (2 * (rightThighLength / 3));

  bool eyeLevelWithMidPoints =
      leftThighThreshold >= leftEye.y && rightThighThreshold >= rightEye.y;

  return eyeLevelWithMidPoints;
}

bool isFinishedRussianTwistPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
  PoseLandmark? rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
  if (leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftShoulder == null ||
      rightShoulder == null ||
      leftElbow == null ||
      rightElbow == null) {
    return false;
  }
  // Process Angles formed by hips
  double leftHipAngle = getAngle(leftShoulder, leftHip, leftKnee);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightKnee);
  double angleThreshold = 90;

  //Process angle formed by hips
  bool hipsFormingAcuteAngle =
      leftHipAngle <= angleThreshold && rightHipAngle <= angleThreshold;

  // Process position of shoulders and knees
  bool shouldersAboveKnees =
      leftShoulder.y >= leftKnee.y && rightShoulder.y >= rightKnee.y;

  // Check if the left elbow OR the right elbow is between the left and right hips
  bool leftElbowBetweenHips =
      leftElbow.x >= leftHip.x && leftElbow.x <= rightHip.x;
  bool rightElbowBetweenHips =
      rightElbow.x >= leftHip.x && rightElbow.x <= rightHip.x;

  return hipsFormingAcuteAngle &&
      shouldersAboveKnees &&
      (leftElbowBetweenHips || rightElbowBetweenHips);
}

bool isStandingPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
  PoseLandmark? rightHeel = pose.landmarks[PoseLandmarkType.rightHeel];

  if (leftShoulder == null ||
      rightShoulder == null ||
      leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftHeel == null ||
      rightHeel == null) {
    return false;
  }

  // Check the vertical order of joints from top to bottom
  //  THE Y VALUE STARTS AT ZERO AT THE TOP THEN LARGER AT THE BOTTOM
  bool isVerticalOrderCorrect = (leftShoulder.y < leftHip.y) &&
      (rightShoulder.y < rightHip.y) &&
      (rightHip.y < rightKnee.y) &&
      (leftHip.y < leftKnee.y) &&
      (leftKnee.y < leftHeel.y) &&
      (rightKnee.y < rightHeel.y);

  double leftHipAngle = getAngle(leftShoulder, leftHip, leftKnee);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightKnee);
  bool isStraightHipAngle = leftHipAngle > 150 && rightHipAngle > 150;

  double leftKneeAngle = getAngle(leftHip, leftKnee, leftHeel);
  double rightKneeAngle = getAngle(rightHip, rightKnee, rightHeel);
  bool isStraightKneeAngle = leftKneeAngle > 150 && rightKneeAngle > 150;
  // Check if the angle is within the upright angle threshold
  return isVerticalOrderCorrect && isStraightKneeAngle && isStraightHipAngle;
}

bool isFinishedSquatPosition(Pose pose) {
  // Assuming landmarks are stored in PoseLandmarkType enum
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
  PoseLandmark? rightHeel = pose.landmarks[PoseLandmarkType.rightHeel];

  if (leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftShoulder == null ||
      rightShoulder == null ||
      leftHeel == null ||
      rightHeel == null) {
    return false;
  }

  double leftHipAngle = getAngle(leftShoulder, leftHip, leftKnee);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightKnee);
  bool isBentHipAngle = leftHipAngle < 100 && rightHipAngle < 100;

  double leftKneeAngle = getAngle(leftHip, leftKnee, leftHeel);
  double rightKneeAngle = getAngle(rightHip, rightKnee, rightHeel);
  bool isBentKneeAngle = leftKneeAngle < 100 && rightKneeAngle < 100;

  // Check if both hips are below the knees
  return isBentHipAngle && isBentKneeAngle;
}

bool isStartingLeftArmWristCurl(Pose pose) {
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
  PoseLandmark? leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
  if (leftElbow == null || leftShoulder == null || leftWrist == null) {
    return false;
  }

  double elbowAngle = getAngle(leftShoulder, leftElbow, leftWrist);
  bool isStretchedOut = elbowAngle > 160;

  return isStretchedOut;
}

bool isStartingRightArmWristCurl(Pose pose) {
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
  PoseLandmark? rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
  if (rightElbow == null || rightShoulder == null || rightWrist == null) {
    return false;
  }

  double elbowAngle = getAngle(rightShoulder, rightElbow, rightWrist);
  bool isStretchedOut = elbowAngle > 160;

  return isStretchedOut;
}

bool isFinishingLeftArmWristCurl(Pose pose) {
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
  PoseLandmark? leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
  if (leftElbow == null || leftShoulder == null || leftWrist == null) {
    return false;
  }

  double elbowAngle = getAngle(leftShoulder, leftElbow, leftWrist);
  bool isFolded = elbowAngle < 55;

  return isFolded;
}

bool isFinishingRightArmWristCurl(Pose pose) {
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
  PoseLandmark? rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];
  if (rightElbow == null || rightShoulder == null || rightWrist == null) {
    return false;
  }

  double elbowAngle = getAngle(rightShoulder, rightElbow, rightWrist);
  bool isFolded = elbowAngle < 55;

  return isFolded;
}

bool isStartingLungePosition(Pose pose) {
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
  PoseLandmark? rightHeel = pose.landmarks[PoseLandmarkType.rightHeel];
  if (leftShoulder == null ||
      rightShoulder == null ||
      leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftHeel == null ||
      rightHeel == null) {
    return false;
  }

  bool isVerticalOrderCorrect = (leftShoulder.y < leftHip.y) &&
      (rightShoulder.y < rightHip.y) &&
      (rightHip.y < rightKnee.y) &&
      (leftHip.y < leftKnee.y) &&
      (leftKnee.y < leftHeel.y) &&
      (rightKnee.y < rightHeel.y);

  double leftHipAngle = getAngle(leftShoulder, leftHip, leftKnee);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightKnee);
  double minHipAngle = 160;
  bool hipsAreStraight =
      leftHipAngle > minHipAngle && rightHipAngle > minHipAngle;

  double leftKneeAngle = getAngle(leftHip, leftKnee, leftHeel);
  double rightKneeAngle = getAngle(rightHip, rightKnee, rightHeel);
  double minKneeAngle = 165;
  bool kneesAreStraight =
      leftKneeAngle > minKneeAngle && rightKneeAngle > minKneeAngle;

  return isVerticalOrderCorrect && hipsAreStraight && kneesAreStraight;
}

bool isFinishingLungePosition(Pose pose) {
  PoseLandmark? leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  PoseLandmark? rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  PoseLandmark? leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  PoseLandmark? rightHip = pose.landmarks[PoseLandmarkType.rightHip];
  PoseLandmark? leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
  PoseLandmark? rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
  PoseLandmark? leftHeel = pose.landmarks[PoseLandmarkType.leftHeel];
  PoseLandmark? rightHeel = pose.landmarks[PoseLandmarkType.rightHeel];
  if (leftShoulder == null ||
      rightShoulder == null ||
      leftHip == null ||
      rightHip == null ||
      leftKnee == null ||
      rightKnee == null ||
      leftHeel == null ||
      rightHeel == null) {
    return false;
  }

  double leftHipAngle = getAngle(leftShoulder, leftHip, leftKnee);
  double rightHipAngle = getAngle(rightShoulder, rightHip, rightKnee);
  double minHipBendAngle = 110;
  double minHipStraightAngle = 150;
  bool leftHipBent = leftHipAngle < minHipBendAngle;
  bool leftHipStraightened = leftHipAngle > minHipStraightAngle;
  bool rightHipBent = rightHipAngle < minHipBendAngle;
  bool rightHipStraightened = rightHipAngle > minHipStraightAngle;

  double leftKneeAngle = getAngle(leftHip, leftKnee, leftHeel);
  double rightKneeAngle = getAngle(rightHip, rightKnee, rightHeel);
  double minKneeAngle = 110;
  bool bothKneesBent =
      leftKneeAngle < minKneeAngle && rightKneeAngle < minKneeAngle;

  double kneeDistance = calculateDistance(leftKnee, rightKnee);
  double hipsLength = calculateDistance(leftHip, rightHip);
  bool kneesAreSpaced = kneeDistance >= 1.5 * hipsLength;

  return bothKneesBent &&
      kneesAreSpaced &&
      ((leftHipBent && rightHipStraightened) ||
          (leftHipStraightened && rightHipBent));
}

//==========================================================================================================================

double calculateDistance(PoseLandmark landmark1, PoseLandmark landmark2) {
  double dx = landmark2.x - landmark1.x;
  double dy = landmark2.y - landmark1.y;

  double distance = sqrt((dx * dx) + (dy * dy));

  return distance;
}

double getAngle(
    PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
  double result = (atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
          atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x)) *
      (180 / pi);
  result = result.abs(); // Angle should never be negative
  if (result > 180) {
    result =
        (360.0 - result); // Always get the acute representation of the angle
  }
  return result;
}
