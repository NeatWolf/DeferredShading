﻿using System;
using System.Collections;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class DSPEVignette : DSEffectBase
{
    public float m_darkness = 0.7f;
    public float m_monochrome = 0.0f;
    public float m_scanline = 0.0f;
    public float m_scanline_scale = 1.0f;
    public Material m_mat_vignette;
    Action m_render;

#if UNITY_EDITOR
    void Reset()
    {
        m_mat_vignette = AssetDatabase.LoadAssetAtPath("Assets/DeferredShading/Materials/Posteffect_Vignette.mat", typeof(Material)) as Material;
    }
#endif

    void OnEnable()
    {
        ResetDSRenderer();
        if (m_render == null)
        {
            m_render = Render;
            GetDSRenderer().AddCallbackPostEffect(m_render, 6000);
        }
    }

    void Render()
    {
        if (!enabled) { return; }

        DSRenderer dsr = GetDSRenderer();
        dsr.SwapFramebuffer();
        m_mat_vignette.SetFloat("g_darkness", m_darkness);
        m_mat_vignette.SetFloat("g_monochrome", m_monochrome);
        m_mat_vignette.SetFloat("g_scanline", m_scanline);
        m_mat_vignette.SetFloat("g_scanline_scale", m_scanline_scale);
        m_mat_vignette.SetPass(0);
        DSRenderer.DrawFullscreenQuad();
    }
}
