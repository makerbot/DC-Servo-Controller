#define QUAD_A_PIN            2
#define QUAD_B_PIN            3
#define DEBUG_PIN             4
#define MOTOR_SPEED_PIN       5
#define MOTOR_DIR_PIN         6
#define MOTOR_SLEEP_PIN       7
#define MOTOR_MODE_PIN        8
#define STEP_PIN              11
#define DIR_PIN               12
#define ENABLE_PIN            13
 
volatile int position;
int target;
 
bool newStep = false;
bool newEnable = false;
bool oldStep = false;
bool oldEnable = true;
bool dir = false;
 
void setup()
{
    Serial.begin(19200);
    Serial.println("MakerBot DC Servo Controller v1.0");
 
    pinMode(QUAD_A_PIN, INPUT);
    pinMode(QUAD_B_PIN, INPUT);
 
    pinMode(DEBUG_PIN, OUTPUT);
 
    pinMode(MOTOR_SLEEP_PIN, OUTPUT);
    digitalWrite(MOTOR_SLEEP_PIN, LOW);
 
    pinMode(MOTOR_MODE_PIN, OUTPUT);
    digitalWrite(MOTOR_MODE_PIN, LOW);
 
    pinMode(MOTOR_SPEED_PIN, OUTPUT);
    digitalWrite(MOTOR_SPEED_PIN, LOW);
 
    pinMode(MOTOR_DIR_PIN, OUTPUT);
    digitalWrite(MOTOR_DIR_PIN, LOW);
 
    pinMode(STEP_PIN, INPUT);
    pinMode(DIR_PIN, INPUT);
    pinMode(ENABLE_PIN, INPUT);
 
    attachInterrupt(0, read_quadrature_a, CHANGE);
    attachInterrupt(1, read_quadrature_b, CHANGE);
}
 
void loop()
{
    newEnable = digitalRead(ENABLE_PIN);
    newStep = digitalRead(STEP_PIN);
    dir = digitalRead(DIR_PIN);
 
    //low to high transition
    if (!oldEnable && newEnable)
    {
        //enable is active low, so disable.
        digitalWrite(MOTOR_SLEEP_PIN, LOW);
        digitalWrite(MOTOR_SPEED_PIN, LOW);
    }
    // high to low transition
    else if (oldEnable && !newEnable)
    {
        //enable is active low, so enable.
        digitalWrite(MOTOR_SLEEP_PIN, HIGH);
        delay(1); //give it a millisecond to turn on.
    }
 
    //enable is active low, so only do this if we're enabled.
    if (!newEnable)
    {
        // step signal is on the low to high transition.
        if (!oldStep && newStep)
        {
            if (dir)
                target++;
            else
                target--;
        }
 
                byte motor_speed = 0;
                int distance = abs(position-target);
                if (distance > 255)
                  motor_speed = 255;
                else
                  motor_speed = distance;
 
        //super primitive control of the motor.
        if (position > target)
        {
            digitalWrite(MOTOR_DIR_PIN, HIGH);
            analogWrite(MOTOR_SPEED_PIN, motor_speed);
        }
        else if (position < target)
        {
            digitalWrite(MOTOR_DIR_PIN, LOW);
            digitalWrite(MOTOR_SPEED_PIN, motor_speed);
        }
        else
        {
            digitalWrite(MOTOR_SPEED_PIN, LOW);
        }
 
        oldStep = newStep;
    }
 
    oldEnable = newEnable;
 
        /*
          delay(1000);
          Serial.print("Pos:");
          Serial.println(position, DEC);
        */
}
 
void read_quadrature_a()
{
    // found a low-to-high on channel A
    if (digitalRead(QUAD_A_PIN) == HIGH)
    {
        // check channel B to see which way
        if (digitalRead(QUAD_B_PIN) == LOW)
            position--;
        else
            position++;
    } // found a high-to-low on channel A
    else
    { // check channel B to see which way
         if (digitalRead(QUAD_B_PIN) == LOW)
             position++;
         else
            position--;
    }
}
 
void read_quadrature_b()
{
    // found a low-to-high on channel A
    if (digitalRead(QUAD_B_PIN) == HIGH)
    {
        // check channel B to see which way
        if (digitalRead(QUAD_A_PIN) == LOW)
            position++;
        else
            position--;
    } // found a high-to-low on channel A
    else
    { // check channel B to see which way
         if (digitalRead(QUAD_A_PIN) == LOW)
             position--;
         else
            position++;
    }
}

