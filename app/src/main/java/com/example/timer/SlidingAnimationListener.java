package com.example.timer;

import android.view.View;
import android.view.animation.Animation;
import android.widget.LinearLayout;

public class SlidingAnimationListener implements Animation.AnimationListener{
    private boolean isPageState = false;
    private final LinearLayout layout;

    public SlidingAnimationListener(LinearLayout layout){
        this.layout = layout;
    }

    @Override
    public void onAnimationStart(Animation animation) { }

    @Override
    public void onAnimationEnd(Animation animation) {
        if(isPageState) layout.setVisibility(View.INVISIBLE);
        isPageState = !isPageState;
    }

    @Override
    public void onAnimationRepeat(Animation animation) {

    }

    public boolean getIsPageState(){
        return isPageState;
    }
}
