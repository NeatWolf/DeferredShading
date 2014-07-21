﻿using UnityEngine;
using System.Collections;

public class Player : MonoBehaviour {

	Transform trans;
	Rigidbody rigid;
	Vector4 glowColor = new Vector4(0.1f, 0.075f, 0.2f, 0.0f);

	void Start()
	{
		trans = GetComponent<Transform>();
		rigid = GetComponent<Rigidbody>();
	}

	void Update()
	{
		MeshRenderer mr = GetComponent<MeshRenderer>();
		mr.material.SetVector("_GlowColor", glowColor);

		if (Input.GetButtonDown("Fire1"))
		{
			Shot();
		}
		{
			Vector3 move = Vector3.zero;
			move.x = Input.GetAxis("Horizontal");
			move.y = Input.GetAxis("Vertical");
			rigid.velocity = move*10.0f;
		}
		{
			Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
			Plane plane = new Plane(Vector3.up, Vector3.zero);
			float distance = 0;
			if (plane.Raycast(ray, out distance))
			{
				trans.rotation = Quaternion.LookRotation(ray.GetPoint(distance) - trans.position);
			}
		}
	}

	void Shot()
	{
	}
}