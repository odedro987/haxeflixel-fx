vec2 offsetToCenter(vec2 uv){
    float xSign = openfl_TextureCoord.x == 0. ? 1. : -1.;
    float ySign = openfl_TextureCoord.y == 0. ? 1. : -1.;

    float xOffset = (openfl_TextureSize.x / 2.) * xSign;
    float yOffset = (openfl_TextureSize.y / 2.) * ySign;

    return vec2(uv.x + xOffset, uv.y + yOffset);
}

mat2 rotateDeg(float angle){
    angle *= (3.14 / 180.);
    return mat2(cos(angle),-sin(angle),
                sin(angle),cos(angle));
}

mat2 rotateRad(float rad){
    return mat2(cos(rad),-sin(rad),
                sin(rad),cos(rad));
}

float sine(float x, float offset, float amplitude, float frequency){
    return amplitude * sin((x + offset) * frequency);
}

float combineSines(float x, float[16] amplitudes, float[16] frequencies, int cutoff){
    float y = 0.;
    for (int i = 0; i < 16; i+=1){
        if(i == cutoff)
            break;
        y += amplitudes[i] * sin(x * frequencies[i]);
    }
    return y;
}