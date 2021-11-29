/*  CRT shader
 *
 *  Copyright (C) 2010-2012 cgwg, Themaister and DOLLS
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  Conversion for MAME/MAMEUIFX done by Hunter K. and U-MAN.
 */

varying float CRTgamma;
varying float monitorgamma;
varying vec2 overscan;
varying vec2 aspect;
varying float d;
varying float R;
varying float cornersize;
varying float cornersmooth;
varying float halation;

varying vec3 stretch;
varying vec2 sinangle;
varying vec2 cosangle;

uniform vec2 color_texture_sz;      // = rubyInputSize
uniform vec2 color_texture_pow2_sz; // = rubyTextureSize

varying vec2 texCoord;
varying vec2 one;

#define FIX(c) max(abs(c), 1e-5);

float intersect(vec2 xy)
{
  float A = dot(xy,xy)+d*d;
  float B = 2.0*(R*(dot(xy,sinangle)-d*cosangle.x*cosangle.y)-d*d);
  float C = d*d + 2.0*R*d*cosangle.x*cosangle.y;
  return (-B-sqrt(B*B-4.0*A*C))/(2.0*A);
}

vec2 bkwtrans(vec2 xy)
{
  float c = intersect(xy);
  vec2 point = vec2(c)*xy;
  point -= vec2(-R)*sinangle;
  point /= vec2(R);
  vec2 tang = sinangle/cosangle;
  vec2 poc = point/cosangle;
  float A = dot(tang,tang)+1.0;
  float B = -2.0*dot(poc,tang);
  float C = dot(poc,poc)-1.0;
  float a = (-B+sqrt(B*B-4.0*A*C))/(2.0*A);
  vec2 uv = (point-a*sinangle)/cosangle;
  float r = R*acos(a);
  return uv*r/sin(r/R);
}

vec2 fwtrans(vec2 uv)
{
  float r = FIX(sqrt(dot(uv,uv)));
  uv *= sin(r/R)/r;
  float x = 1.0-cos(r/R);
  float D = d/R + x*cosangle.x*cosangle.y+dot(uv,sinangle);
  return d*(uv*cosangle-x*sinangle)/D;
}

vec3 maxscale()
{
  vec2 c = bkwtrans(-R * sinangle / (1.0 + R/d*cosangle.x*cosangle.y));
  vec2 a = vec2(0.5,0.5)*aspect;
  vec2 lo = vec2(fwtrans(vec2(-a.x,c.y)).x,
		 fwtrans(vec2(c.x,-a.y)).y)/aspect;
  vec2 hi = vec2(fwtrans(vec2(+a.x,c.y)).x,
		 fwtrans(vec2(c.x,+a.y)).y)/aspect;
  return vec3((hi+lo)*aspect*0.5,max(hi.x-lo.x,hi.y-lo.y));
}


void main()
{

  // START of parameters

  // gamma of simulated CRT
  CRTgamma = 2.4;
  // gamma of display monitor (typically 2.2 is correct)
  monitorgamma = 2.2;
  // overscan (e.g. 1.02 for 2% overscan)
  overscan = vec2(0.98,0.98);
  // aspect ratio
  aspect = vec2(1.0, 0.75);
  // lengths are measured in units of (approximately) the width of the monitor
  // simulated distance from viewer to monitor
  d = 2.0;
  // radius of curvature
  R = 3.5;
  // tilt angle in radians
  // (behavior might be a bit wrong if both components are nonzero)
  const vec2 angle = vec2(0.01,0.0);
  // size of curved corners
  cornersize = 0.03;
  // border smoothness parameter
  // decrease if borders are too aliased
  cornersmooth = 100.0;
  // strength of halation or "bloom" effect - e.g. 0.1 for 10%
  halation = 0.1;

  // END of parameters

  // Do the standard vertex processing.
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

  // Precalculate a bunch of useful values we'll need in the fragment
  // shader.
  sinangle = sin(angle);
  cosangle = cos(angle);
  stretch = maxscale();

  // Texture coords.
  texCoord = gl_MultiTexCoord0.xy;

  // The size of one texel, in texture-coordinates.
  one = 1.0 / color_texture_pow2_sz;  
}