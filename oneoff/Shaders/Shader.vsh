//
//  Shader.vsh
//  CubeExample
//
//  Created by Brad Larson on 4/20/2010.
//

attribute vec4 position;
attribute vec4 inputTextureCoordinate;

varying vec2 textureCoordinate;

uniform mat4 modelViewProjMatrix;

void main()
{
    gl_Position = modelViewProjMatrix * position;
	textureCoordinate = inputTextureCoordinate.xy;
}
