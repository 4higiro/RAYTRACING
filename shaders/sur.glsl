#version 130

uniform vec2 resolution;
uniform vec3 position;
uniform mat3 view;
uniform int ref_count;
uniform float seed;

struct sphere
{
	vec3 o;
	vec3 color;
	float r;
	int type;
};

struct plane
{
	vec3 i, j, k;
	vec3 color;
	int type;
};

vec2 random(vec2 p)
{
	p+= seed;
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031f, 0.1030f, 0.0973f));
	p3 += dot(p3, p3.yzx + 33.33f);
	return fract((p3.xx + p3.yz) * p3.zy);
}

vec3 sphereIntersect(sphere s, vec3 ro, vec3 rd)
{
	vec3 a = rd * rd;
	vec3 b = 2.0f * ro * rd - 2.0f * s.o * rd;
	vec3 c = ro * ro - 2.0f * s.o * ro + s.o * s.o;
	float A = a.x + a.y + a.z;
	float B = b.x + b.y + b.z;
	float C = c.x + c.y + c.z - s.r * s.r;
	float D = B * B - 4.0f * A * C;
	if (D >= 0.0f)
	{
		float t1 = (-B - sqrt(D)) / (2.0f * A);
		float t2 = (-B + sqrt(D)) / (2.0f * A);
		if (t1 < 0.0f && t2 < 0.0f)
			return vec3(0.0f, 0.0f, 0.0f);
		float t = min(t1, t2);
		if (t1 < 0.0f)
			t = t2;
		if (t2 < 0.0f)
			t = t1;
		return ro + rd * t;
	}
	else
		return vec3(0.0f, 0.0f, 0.0f);
}

vec3 planeIntersect(plane p, vec3 ro, vec3 rd)
{
	float A = (p.j.y - p.i.y) * (p.k.z - p.i.z) - (p.j.z - p.i.z) * (p.k.y - p.i.y);
	float B = (p.j.z - p.i.z) * (p.k.x - p.i.x) - (p.j.x - p.i.x) * (p.k.z - p.i.z);
	float C = (p.j.x - p.i.x) * (p.k.y - p.i.y) - (p.j.y - p.i.y) * (p.k.x - p.i.x);
	float D = -1.0f * (B * p.i.y + A * p.i.x + C * p.i.z);
	float t1 = -1.0f * (D + A * ro.x + B * ro.y + C * ro.z);
	float t2 = A * rd.x + B * rd.y + C * rd.z;
	if (t2 == 0.0f)
		return vec3(0.0f, 0.0f, 0.0f);
	float t = t1 / t2;
	if (t >= 0.0f)
		return ro + rd * t;
	else
		return vec3(0.0f, 0.0f, 0.0f);
}

vec3 sphereNorm(sphere s, vec3 point)
{
	return normalize(point - s.o);
}

vec3 planeNorm(plane p)
{
	float A = (p.j.y - p.i.y) * (p.k.z - p.i.z) - (p.j.z - p.i.z) * (p.k.y - p.i.y);
	float B = (p.j.z - p.i.z) * (p.k.x - p.i.x) - (p.j.x - p.i.x) * (p.k.z - p.i.z);
	float C = (p.j.x - p.i.x) * (p.k.y - p.i.y) - (p.j.y - p.i.y) * (p.k.x - p.i.x);
	return normalize(-vec3(A, B, C));
}

vec3 gammaCorrection(vec3 color)
{
	return vec3(pow(color.x, 1.0f/1.8f), pow(color.y, 1.0f/1.8f), pow(color.z, 1.0f/1.8f));
}

float reduced(float value, int t)
{
	if (t == 0)
		return 1.0f;
	else
		return value;
}

void main()
{
	vec2 uv = vec2(gl_TexCoord[0].xy - 0.5f) * resolution / resolution.y;
	vec3 ro = vec3(0.0f, 0.0f, 0.0f);
	vec3 rd = normalize(vec3(uv, 1.0f));


	plane wall1, wall2, wall3, wall4, wall5, wall6;
	sphere s1, s2;
	sphere light;

	wall1.i = view * (vec3(0.0f, 0.0f, 0.0f) - position);
	wall1.j = view * (vec3(1.0f, 0.0f, 0.0f) - position);
	wall1.k = view * (vec3(0.0f, 0.0f, 1.0f) - position);
	wall1.color = vec3(0.5f, 0.5f, 0.5f);
	wall1.type = 2;

	wall2.i = view * (vec3(-1.5f, 0.0f, 0.0f) - position);
	wall2.j = view * (vec3(-1.5f, 1.0f, 0.0f) - position);
	wall2.k = view * (vec3(-1.5f, 0.0f, 1.0f) - position);
	wall2.color = vec3(0.5f, 0.5f, 1.0f);
	wall2.type = 2;

	wall3.i = view * (vec3(1.5f, 0.0f, 0.0f) - position);
	wall3.j = view * (vec3(1.5f, 1.0f, 0.0f) - position);
	wall3.k = view * (vec3(1.5f, 0.0f, 1.0f) - position);
	wall3.color = vec3(1.0f, 0.5f, 0.5f);
	wall3.type = 2;

	wall4.i = view * (vec3(0.0f, 1.5f, 0.0f) - position);
	wall4.j = view * (vec3(1.0f, 1.5f, 0.0f) - position);
	wall4.k = view * (vec3(0.0f, 1.5f, 1.0f) - position);
	wall4.color = vec3(0.5f, 0.5f, 0.5f);
	wall4.type = 2;

	wall5.i = view * (vec3(0.0f, 0.0f, -1.5f) - position);
	wall5.j = view * (vec3(1.0f, 0.0f, -1.5f) - position);
	wall5.k = view * (vec3(0.0f, 1.0f, -1.5f) - position);
	wall5.color = vec3(1.0f, 1.0f, 0.5f);
	wall5.type = 2;

	wall6.i = view * (vec3(0.0f, 0.0f, 1.5f) - position);
	wall6.j = view * (vec3(1.0f, 0.0f, 1.5f) - position);
	wall6.k = view * (vec3(0.0f, 1.0f, 1.5f) - position);
	wall6.color = vec3(0.5f, 1.0f, 0.5f);
	wall6.type = 2;

	light.o = view * (vec3(0.0f, 1.5f, 0.0f) - position);
	light.r = 0.2f;
	light.color = vec3(1.0f, 1.0f, 1.0f);
	light.type = 0;
	
	s1.o = view * (vec3(-0.75f, 0.5f, 1.0f) - position);
	s1.r = 0.5f;
	s1.color = vec3(1.0f, 0.5f, 0.5f);
	s1.type = 1;

	s2.o = view * (vec3(0.75f, 0.5f, 1.0f) - position);
	s2.r = 0.5f;
	s2.color = vec3(0.5f, 0.5f, 1.0f);
	s2.type = 1;

	vec3 color = vec3(0.0f, 0.0f, 0.0f);
	vec3 light_color = vec3(1.0f, 1.0f, 1.0f);

	vec3 n = vec3(0.0f, 1.0f, 0.0f);
	vec3 point = vec3(0.0f, 0.0f, 0.0f);

	bool sky, light_source;

	for (int t = 0; t < ref_count; t++)
	{
		vec3 n = vec3(0.0f, 1.0f, 0.0f);
		vec3 point = vec3(0.0f, 0.0f, 0.0f);
		int type = 0;

		vec3 point_w1 = planeIntersect(wall1, ro, rd);
		vec3 point_w2 = planeIntersect(wall2, ro, rd);
		vec3 point_w3 = planeIntersect(wall3, ro, rd);
		vec3 point_w4 = planeIntersect(wall4, ro, rd);
		vec3 point_w5 = planeIntersect(wall5, ro, rd);
		vec3 point_w6 = planeIntersect(wall6, ro, rd);

		vec3 point_l = sphereIntersect(light, ro, rd);

		vec3 point_s1 = sphereIntersect(s1, ro, rd);
		vec3 point_s2 = sphereIntersect(s2, ro, rd);

		sky = true;
		light_source = false;

		if (point_w1 != vec3(0.0f))
		{
			point = point_w1;
			n = planeNorm(wall1);
			color = wall1.color;
			type = wall1.type;
			sky = false;
		}
		if (point_w2 != vec3(0.0f) && (length(point_w2 - ro) < length(point - ro) || sky))
		{
			point = point_w2;
			n = planeNorm(wall2);
			color = wall2.color;
			type = wall2.type;
			sky = false;
		}
		if (point_w3 != vec3(0.0f) && (length(point_w3 - ro) < length(point - ro) || sky))
		{
			point = point_w3;
			n = planeNorm(wall3);
			color = wall3.color;
			type = wall3.type;
			sky = false;
		}
		if (point_w4 != vec3(0.0f) && (length(point_w4 - ro) < length(point - ro) || sky))
		{
			point = point_w4;
			n = planeNorm(wall4);
			color = wall4.color;
			type = wall4.type;
			sky = false;
		}
		if (point_w5 != vec3(0.0f) && (length(point_w5 - ro) < length(point - ro) || sky))
		{
			point = point_w5;
			n = planeNorm(wall5);
			color = wall5.color;
			type = wall5.type;
			sky = false;
		}
		if (point_w6 != vec3(0.0f) && (length(point_w6 - ro) < length(point - ro) || sky))
		{
			point = point_w6;
			n = planeNorm(wall6);
			color = wall6.color;
			type = wall6.type;
			sky = false;
		}
		if (point_l != vec3(0.0f) && (length(point_l - ro) < length(point - ro) || sky))
		{
			point = point_l;
			n = sphereNorm(light, point_l);
			color = light.color;
			type = light.type;
			sky = false;
		}
		if (point_s1 != vec3(0.0f) && (length(point_s1 - ro) < length(point - ro) || sky))
		{
			point = point_s1;
			n = sphereNorm(s1, point_s1);
			color = s1.color;
			type = s1.type;
			sky = false;
		}
		if (point_s2 != vec3(0.0f) && (length(point_s2 - ro) < length(point - ro) || sky))
		{
			point = point_s2;
			n = sphereNorm(s2, point_s2);
			color = s2.color;
			type = s2.type;
			sky = false;
		}

		if (dot(rd, n) > 0.0f)
			n = -n;
		ro = point + 0.001f * n;

		if (!sky)
			light_color *= color * reduced(0.9f, t);
		
		if (sky)
		{
			color = light_color * vec3(0.5f, 0.8f, 1.0f);
			break;
		}
		else if (type == 0)
		{
			color = light_color * pow(2.0f, t);
			light_source = true;
			break;
		}
		else if (type == 1)
		{
			rd = normalize(reflect(rd, n));
		}
		else if (type == 2)
		{
			vec2 r = random(uv);
			vec3 rand = vec3(r, r.x * r.y);
			rd = normalize(rand * dot(rand, n));
			color = light_color;
			sky = true;
			break;
		}
	}

	if (!sky && !light_source)
		color = vec3(0.0f, 0.0f, 0.0f);

	if (uv.x * uv.x + uv.y * uv.y <= 0.0001f)
		color += vec3(0.3f);

	color = gammaCorrection(color);

	gl_FragColor = vec4(color, 1.0f);
}