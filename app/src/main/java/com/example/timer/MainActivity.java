package com.example.timer;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.*;

import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends AppCompatActivity {
    boolean started, paused;
    NumberPicker hourET, minuteET, secondET;
    int[] savedClock = {0, 0, 0};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        LinearLayout timeCountSettingLV = (LinearLayout)findViewById(R.id.timeCountSettingLV);
        LinearLayout timeCountLV = (LinearLayout)findViewById(R.id.timeCountLV);

        hourET = (NumberPicker)findViewById(R.id.hourET);
        minuteET = (NumberPicker)findViewById(R.id.minuteET);
        secondET = (NumberPicker)findViewById(R.id.secondET);

        TextView hourTV = (TextView)findViewById(R.id.hourTV);
        TextView minuteTV = (TextView)findViewById(R.id.minuteTV);
        TextView secondTV = (TextView)findViewById(R.id.secondTV);

        Button startBtn = (Button)findViewById(R.id.startBtn);

        hourET.setFormatter(v -> v + "시간");
        minuteET.setFormatter(v -> v + "분");
        secondET.setFormatter(v -> v + "초");
        hourET.setMaxValue(48);
        minuteET.setMaxValue(59);
        secondET.setMaxValue(59);

        // 시작버튼 이벤트 처리
        startBtn.setOnClickListener(view -> {
            paused = !paused;
            started = !started;

            startBtn.setText("일시중지");
            timeCountSettingLV.setVisibility(View.GONE);
            timeCountLV.setVisibility(View.VISIBLE);

            final int[] clock = paused ? new int[]{hourET.getValue(), minuteET.getValue(), secondET.getValue()} : savedClock;
            if(!started){
                Toast.makeText(getApplicationContext(), "타이머가 일시중지되었습니다.", Toast.LENGTH_SHORT).show();
                return;
            }

            hourTV.setText((clock[0] <= 9 ? "0" : "") + clock[0] + "시간");
            minuteTV.setText((clock[1] <= 9 ? "0" : "") + clock[1] + "분");
            secondTV.setText((clock[2] <= 9 ? "0" : "") + clock[2] + "초");

            Timer timer = new Timer();
            TimerTask timerTask = new TimerTask() {
                @Override
                public void run() { // 반복실행할 구문
                    if(!started) {
                        runOnUiThread(() -> {
                            paused = true;
                            savedClock = clock;
                            hourTV.setText((clock[0] <= 9 ? "0" : "") + clock[0] + "시간");
                            minuteTV.setText((clock[1] <= 9 ? "0" : "") + clock[1] + "분");
                            secondTV.setText((clock[2] <= 9 ? "0" : "") + clock[2] + "초");
                            //timeCountSettingLV.setVisibility(View.VISIBLE);
                            //timeCountLV.setVisibility(View.GONE);
                            startBtn.setText("재시작");
                        });
                        timer.cancel();
                        return;
                    }

                    // 시분초가 다 0이라면 toast 를 띄우고 타이머를 종료한다..
                    if(clock[0] == 0 && clock[1] == 0 && clock[2] == 0) {
                        started = false;
                        runOnUiThread(() -> {
                            timeCountSettingLV.setVisibility(View.VISIBLE);
                            timeCountLV.setVisibility(View.GONE);
                            startBtn.setText("시작");
                        });
                        new Handler(Looper.getMainLooper()).postDelayed(() -> Toast.makeText(getApplicationContext(), "타이머가 종료되었습니다.", Toast.LENGTH_SHORT).show(), 0);
                        timer.cancel();//타이머 종료
                    }

                    //시, 분, 초가 한자리수라면 숫자 앞에 0을 붙인다
                    secondTV.setText((clock[2] <= 9 ? "0" : "") + clock[2] + "초");
                    minuteTV.setText((clock[1] <= 9 ? "0" : "") + clock[1] + "분");
                    hourTV.setText((clock[0] <= 9 ? "0" : "") + clock[0] + "시간");

                    if(clock[2] > 0) { // 1초 이상이면
                        clock[2]--;
                    } else if(clock[1] > 0) { // 1분 이상이면
                        clock[2] = 60;

                        clock[2]--;
                        clock[1]--;
                    } else if(clock[0] > 0) { // 1시간 이상이면
                        clock[2] = 60;
                        clock[1] = 60;

                        clock[2]--;
                        clock[1]--;
                        clock[0]--;
                    }
                }
            };

            //타이머를 실행
            timer.schedule(timerTask, 0, 1000); //Timer 실행
        });
    }
}