// 【タクトスイッチで起動・初期角度設定版】
// タクトスイッチを押すまで停止、押したら初期角度設定して動作開始
// No(false)が表示されたとき ＝ ボールを掴んでいる ＝ 正面キープ(BNO)
// Noではない(true)とき ＝ ボールを探している ＝ 追跡(IR)

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <Servo.h>

#define A1 2
#define A2 3
#define B1 6
#define B2 7

const int ESC_PIN = 44;
const int HOLD_SENSOR_PIN = 64; 
const int TACT_SWITCH_PIN = 22;  // タクトスイッチのピン

const float Kp_IR  = 3.5;   
const float Kp_BNO = 2.5;   

const int MAX_SPEED = 225;
const int MIN_SPEED = 100;

const int FORWARD_SPEED = 140;   // 基本前進速度
const float TURN_GAIN = 1.8;     // 旋回の強さ

const int DRIBBLER_SPEED = 1500;

Adafruit_BNO055 bno = Adafruit_BNO055(55);
Servo esc;

float targetAngle = 999.0; 
float initialHeading = 0;   
bool bnoActive = false;      // BNOを使用するかどうか
bool wasHolding = false;     // 前回のホールド状態
bool systemRunning = false;  // システム動作中フラグ（true=動作、false=停止）

bool lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50;

// 壁検出用
float lastHeading = 0;
unsigned long stuckStartTime = 0;
bool isStuck = false;
const float STUCK_THRESHOLD = 2.0;  // 角度変化がこれ以下なら壁判定
const unsigned long STUCK_TIME = 5000;  // 0.5秒動かなかったら壁
const int BACKUP_SPEED = 150;
const unsigned long BACKUP_DURATION = 1000;  // 後退時間（ミリ秒）

bool readHoldStable() {
  const int samples = 7;
  int lowCount = 0;
  for (int i = 0; i < samples; i++) {
    if (digitalRead(HOLD_SENSOR_PIN) == LOW) lowCount++;
    delayMicroseconds(300);
  }
  return (lowCount > samples / 2);
}

void setInitialHeading() {
  sensors_event_t event;
  bno.getEvent(&event);
  initialHeading = event.orientation.x;
  Serial.print("Initial Heading set: ");
  Serial.println(initialHeading);
}

void stopMotors() {
  digitalWrite(A1, LOW);
  analogWrite(A2, 0);
  digitalWrite(B1, LOW);
  analogWrite(B2, 0);
}

void backupFromWall() {
  Serial.println("壁検出！後退します");
  
  // 後退
  digitalWrite(A1, LOW);
  analogWrite(A2, BACKUP_SPEED);
  digitalWrite(B1, LOW);
  analogWrite(B2, BACKUP_SPEED);
  
  delay(BACKUP_DURATION);
  
  // 少し回転してリトライ
  digitalWrite(A1, HIGH);
  analogWrite(A2, 120);
  digitalWrite(B1, LOW);
  analogWrite(B2, 120);
  
  delay(300);
  
  isStuck = false;
  stuckStartTime = 0;
  Serial.println("リトライ");
}

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200); 

  pinMode(A1, OUTPUT); pinMode(A2, OUTPUT);
  pinMode(B1, OUTPUT); pinMode(B2, OUTPUT);
  pinMode(HOLD_SENSOR_PIN, INPUT);
  pinMode(TACT_SWITCH_PIN, INPUT_PULLUP);  // プルアップ抵抗を有効化

  esc.attach(ESC_PIN);
  esc.writeMicroseconds(1000); 
  delay(3000);

  if (bno.begin()) {
    delay(1000);
    setInitialHeading();  // 起動時に初期角度を設定
    Serial.println("BNO055 ready!");
    Serial.println("タクトスイッチを押してスタート/ストップ");
  } else {
    Serial.println("BNO055 connection failed!");
  }
  
  stopMotors();  // 初期状態で停止
}

void loop() {
  // --- タクトスイッチのチャタリング対策処理 ---
  int buttonReading = digitalRead(TACT_SWITCH_PIN);
  
  if (buttonReading != lastButtonState) {
    lastDebounceTime = millis();
  }
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
    if (buttonReading == LOW) {  // スイッチが押された
      // スタート/ストップ切り替え
      systemRunning = !systemRunning;
      
      if (systemRunning) {
        Serial.println("スタート！");
      } else {
        Serial.println("ストップ");
      }
      delay(200);  // 連続押下防止
    }
  }
  
  lastButtonState = buttonReading;

  // システム停止中の場合は停止状態を維持
  if (!systemRunning) {
    esc.writeMicroseconds(1000);  // ドリブラー停止
    stopMotors();
    return;  // ここで処理終了
  }

  // --- 以下、システム起動後の通常動作 ---
  esc.writeMicroseconds(DRIBBLER_SPEED);

  // BNOで現在の角度を取得
  sensors_event_t event;
  bno.getEvent(&event);
  float currentHeading = event.orientation.x;

  // 壁検出：角度変化が小さい状態が続いたら
  float headingChange = abs(currentHeading - lastHeading);
  if (headingChange > 180) headingChange = 360 - headingChange;  // 角度の折り返し対応

  if (headingChange < STUCK_THRESHOLD) {
    if (stuckStartTime == 0) {
      stuckStartTime = millis();  // カウント開始
    } else if (millis() - stuckStartTime > STUCK_TIME) {
      // 一定時間動いていない → 壁にぶつかった
      backupFromWall();
      lastHeading = currentHeading;
      return;  // 後退後、次のループへ
    }
  } else {
    stuckStartTime = 0;  // 動いているのでリセット
  }

  lastHeading = currentHeading;

  bool isDetected = readHoldStable();
  if (Serial1.available() > 0) targetAngle = Serial1.parseFloat();

  float angle = 0;

  // --- ホールド検出時にBNO作動ON ---
  if (isDetected == false && !wasHolding) {
    // ボールをキャッチした瞬間
    bnoActive = true;
    Serial.println("BNO activated!");
  }

  // --- 状態判定 ---
  if (isDetected == false && bnoActive) {
    // ボール保持中：BNOで正面キープ
    float error = currentHeading - initialHeading;
    if (error > 180)  error -= 360;
    if (error < -180) error += 360;

    angle = error;

    Serial.print("HOLD | error:");
    Serial.println(error);
  } 
  else if (isDetected == true) {
    // ボール探索中：IR追跡
    bnoActive = false;  // ボールを離したらBNO無効化
    
    if (targetAngle != 999.0) {
      angle = targetAngle;

      Serial.print("SEARCH | angle:");
      Serial.println(targetAngle);
    }
  }

  // 前回の状態を保存
  wasHolding = !isDetected;

  // --- 前進＋旋回制御 ---
  int baseSpeed = FORWARD_SPEED;
  int turnSpeed = abs(angle) * TURN_GAIN;

  turnSpeed = constrain(turnSpeed, 0, MAX_SPEED);

  int leftSpeed, rightSpeed;

  if (abs(angle) < 3.0) {
    // 正面 → まっすぐ前進
    leftSpeed  = baseSpeed;
    rightSpeed = baseSpeed;
  }
  else if (angle > 0) {
    // 右にズレ → 右を遅く
    leftSpeed  = baseSpeed + turnSpeed;
    rightSpeed = baseSpeed - turnSpeed;
  }
  else {
    // 左にズレ → 左を遅く
    leftSpeed  = baseSpeed - turnSpeed;
    rightSpeed = baseSpeed + turnSpeed;
  }

  leftSpeed  = constrain(leftSpeed,  MIN_SPEED, MAX_SPEED);
  rightSpeed = constrain(rightSpeed, MIN_SPEED, MAX_SPEED);

  // 左モーター
  digitalWrite(A1, HIGH);
  analogWrite(A2, leftSpeed);

  // 右モーター
  digitalWrite(B1, HIGH);
  analogWrite(B2, rightSpeed);

  Serial.print("L:");
  Serial.print(leftSpeed);
  Serial.print(" R:");
  Serial.println(rightSpeed);
}