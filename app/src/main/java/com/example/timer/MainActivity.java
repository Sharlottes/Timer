package com.example.timer;

import androidx.appcompat.app.AppCompatActivity;

import android.media.Image;
import android.os.*;
import android.text.Editable;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.*;

import java.util.*;

public class MainActivity extends AppCompatActivity {
    boolean started, paused;
    NumberPicker hourNP, minuteNP, secondNP;
    EditText hourET, minuteET, secondET;
    int[] savedClock = {0, 0, 0};

    private LinearLayout ll_page;
    private ImageButton btn_slide;
    private Animation ani_left, ani_right;
    private boolean isPageState;

    public int getNumber(Editable s){
        String str = s.toString().replaceAll("\\D", "");
        if(str.length() > 1) {
            if(str.length() > String.valueOf(Integer.MAX_VALUE).length()) {
                str = str.substring(0, String.valueOf(Integer.MAX_VALUE).length());
                Toast.makeText(getApplicationContext(), "숫자가 너무 큽니다.", Toast.LENGTH_SHORT).show();
            }
        }

        return str.isEmpty() ? 0 : Integer.parseInt(str);
    }

    private void initView() {
        ll_page = findViewById(R.id.ll_page);
        btn_slide = findViewById(R.id.btn_slide);
        ani_left = AnimationUtils.loadAnimation(this, R.anim.translate_left);
        ani_right = AnimationUtils.loadAnimation(this, R.anim.translate_right);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initView();

        final SlidingAnimationListener listener = new SlidingAnimationListener(ll_page);
        ani_left.setAnimationListener(listener);
        ani_right.setAnimationListener(listener);

        btn_slide.setOnClickListener(v -> {
            isPageState = listener.getIsPageState();
            if(isPageState) {
                ll_page.startAnimation(ani_left);
            } else {
                ll_page.setVisibility(View.VISIBLE);
                ll_page.startAnimation(ani_right);
            }
        });

        LinearLayout timeCountSettingLV = (LinearLayout)findViewById(R.id.timeCountSettingLV);
        LinearLayout timeCountLV = (LinearLayout)findViewById(R.id.timeCountLV);

        hourET = (EditText)findViewById(R.id.hourET);
        minuteET = (EditText)findViewById(R.id.minuteET);
        secondET = (EditText)findViewById(R.id.secondET);
        hourNP = (NumberPicker)findViewById(R.id.hourNP);
        minuteNP = (NumberPicker)findViewById(R.id.minuteNP);
        secondNP = (NumberPicker)findViewById(R.id.secondNP);

        TextView hourTV = (TextView)findViewById(R.id.hourTV);
        TextView minuteTV = (TextView)findViewById(R.id.minuteTV);
        TextView secondTV = (TextView)findViewById(R.id.secondTV);

        Button startBtn = (Button)findViewById(R.id.startBtn);

        hourNP.setFormatter(v -> v + "시간");
        minuteNP.setFormatter(v -> v + "분");
        secondNP.setFormatter(v -> v + "초");
        hourNP.setMaxValue(48);
        minuteNP.setMaxValue(59);
        secondNP.setMaxValue(59);

        hourET.setOnFocusChangeListener((v, hasFocus) -> {
            int hour = getNumber(hourET.getText());
            hourNP.setValue(Math.min(48, hour));
        });
        minuteET.setOnFocusChangeListener((v, hasFocus) -> {
            int minute = getNumber(minuteET.getText());
            if(minute == minuteNP.getValue()){
                if(minute == 0) minuteET.setText("");
                return;
            }
            minuteET.setText((minute % 60 + ""));
            minuteNP.setValue(minute % 60);
            hourET.setText((Math.min(48, minute/60)+""));
            hourNP.setValue(Math.min(48, minute/60));
        });
        secondET.setOnFocusChangeListener((v, hasFocus) -> {
            int second = getNumber(secondET.getText());
            if(second == secondNP.getValue()){
                if(second == 0) secondET.setText("");
                return;
            }
            secondET.setText((second % 60 + ""));
            secondNP.setValue(second % 60);
            minuteET.setText(((second/60)%60+""));
            minuteNP.setValue((second/60)%60);
            hourET.setText((Math.min(48, second/60/60)+""));
            hourNP.setValue(Math.min(48, second/60/60));
        });


        hourNP.setOnValueChangedListener((picker, olds, news) -> hourET.setText(news+""));
        minuteNP.setOnValueChangedListener((picker, olds, news) -> minuteET.setText(news+""));
        secondNP.setOnValueChangedListener((picker, olds, news) -> secondET.setText(news+""));


        // 시작버튼 이벤트 처리
        startBtn.setOnClickListener(view -> {
            paused = !paused;
            started = !started;

            startBtn.setText("일시중지");
            timeCountSettingLV.setVisibility(View.GONE);
            timeCountLV.setVisibility(View.VISIBLE);

            final int[] clock = paused ? new int[]{hourNP.getValue(), minuteNP.getValue(), secondNP.getValue()} : savedClock;
            if(!started){
                Toast.makeText(getApplicationContext(), "타이머가 일시중지되었습니다.", Toast.LENGTH_SHORT).show();
                return;
            }

            hourTV.setText(clock[0] + "시간");
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
                            hourTV.setText(clock[0] + "시간");
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
                    hourTV.setText(clock[0] + "시간");
                    minuteTV.setText((clock[1] <= 9 ? "0" : "") + clock[1] + "분");
                    secondTV.setText((clock[2] <= 9 ? "0" : "") + clock[2] + "초");

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