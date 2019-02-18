using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RadialBlur : PostEffectsBase
{

    public Shader radialBlurShader;

    private Material radialBlurMaterial;

    public Material material
    {
        get
        {
            radialBlurMaterial = CheckShaderAndCreateMaterial(radialBlurShader, radialBlurMaterial);
            return radialBlurMaterial;
        }
    }

	[Range(0, 0.05f)]
	public float _blurFactor = 0.01f;

	[Range(0, 1.0f)]
	public float _lerpValue = 0.5f;

	[Range(1, 4)]
	public int downSample = 1;

    [Range(1, 8)]
    public int _iterations = 6;

    public Vector2 _screenCenter = new Vector2(0.5f, 0.5f);

	void OnRenderImage ( RenderTexture src, RenderTexture dest){

	    if (material != null)
	    {
	        int rtW = src.width / downSample;
	        int rtH = src.height / downSample;

            material.SetFloat("_BlurFactor", _blurFactor);
            material.SetFloat("_LerpValue", _lerpValue);
            material.SetVector("_ScreenCenter", _screenCenter);
            material.SetInt("_Iterations", _iterations);

            RenderTexture rt = RenderTexture.GetTemporary(rtW, rtH, 0);
            //rt存放模糊后图像
            Graphics.Blit(src, rt, material, 0);
            material.SetTexture("_RadialBlurTex", rt);
	        RenderTexture.ReleaseTemporary (rt);
            Graphics.Blit(src, dest, material, 1);
	    }
	    else
	    {
	        Graphics.Blit(src, dest);
	    }

	}
}
