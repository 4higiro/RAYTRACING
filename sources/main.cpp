#include <SFML/Graphics.hpp>
using namespace sf;

#include <iostream>
#include <random>
using namespace std;

float rad(float angle)
{
	float pi = acos(-1);
	return angle * pi / 180.0f;
}

float* multipleMat3f(float* a, float* b, float*& result)
{
	result = new float[9];
	for (int i = 0; i < 9; i++)
		result[i] = 0.0f;
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
		{
			for (int k = 0; k < 3; k++)
				result[i * 3 + j] += a[i * 3 + k] * b[k * 3 + j];
		}
	}
	return result;
}

int main()
{
	cout << "RAYTRACING DEMOSTRATION	(c) DPI NNTU 2023" << endl;
	cout << "1 - OPEN SCENE (REAL)" << endl;
	cout << "2 - CLOSE SCENE (REAL)" << endl;
	cout << "3 - CLOSE SCENE (SURREAL)" << endl;
	int pick = 0;
	cout << "YOUR CHOICE: ";
	cin >> pick;
	string path = "shaders/close_scene.glsl";
	switch (pick)
	{
	case 1:
		path = "shaders/open_scene.glsl";
		break;
	case 2:
		path = "shaders/close_scene.glsl";
		break;
	case 3:
		path = "shaders/sur.glsl";
		break;
	}

	Vector2f resolution = Vector2f(1280, 720);
	RenderWindow window(VideoMode(resolution.x, resolution.y), "Engine");
	VideoMode vm = VideoMode::getDesktopMode();
	window.setFramerateLimit(60);
	window.setMouseCursorVisible(false);

	RenderTexture texture;
	texture.create(resolution.x, resolution.y);
	Sprite sprite = Sprite(texture.getTexture());

	Shader shader;
	shader.loadFromFile(path, sf::Shader::Fragment);
	shader.setUniform("resolution", resolution);
	shader.setUniform("ref_count", 10);

	float* matrix = new float[9];
	for (int i = 0; i < 3; i++)
	{
		for (int j = 0; j < 3; j++)
			matrix[i * 3 + j] = 0.0f;
		matrix[i * 3 + i] = 1.0f;
	}
	Glsl::Mat3 view(matrix);
	shader.setUniform("view", view);

	Vector3f position(0.0f, 0.3f, 0.0f);
	shader.setUniform("position", position);

	int mouse_x = resolution.x / 2;
	int mouse_y = resolution.y / 2;
	Mouse::setPosition(Vector2i(resolution.x / 2, resolution.y / 2), window);
	
	while (window.isOpen())
	{
		shader.setUniform("seed", (float)(rand() % 10));
		Event event;
		while (window.pollEvent(event))
		{
			if (event.type == Event::Closed)
				window.close();

			if (event.type == Event::KeyPressed)
			{
				if(event.key.code == Keyboard::Escape)
					window.close();
				
				if (event.key.code == Keyboard::LShift)
					window.setMouseCursorVisible(true);

				if (event.key.code == Keyboard::W)
				{
					position.x += matrix[2] / sqrt(matrix[2] * matrix[2] + matrix[8] * matrix[8] + 0.01f) / 10.0f;
					position.z += matrix[8] / sqrt(matrix[2] * matrix[2] + matrix[8] * matrix[8] + 0.01f) / 10.0f;
				}

				if (event.key.code == Keyboard::S)
				{
					position.x -= matrix[2] / sqrt(matrix[2] * matrix[2] + matrix[8] * matrix[8] + 0.01f) / 10.0f;
					position.z -= matrix[8] / sqrt(matrix[2] * matrix[2] + matrix[8] * matrix[8] + 0.01f) / 10.0f;
				}

				if (event.key.code == Keyboard::D)
				{
					position.x += matrix[0] / sqrt(matrix[0] * matrix[0] + matrix[6] * matrix[6] + 0.01f) / 10.0f;
					position.z += matrix[6] / sqrt(matrix[0] * matrix[0] + matrix[6] * matrix[6] + 0.01f) / 10.0f;
				}

				if (event.key.code == Keyboard::A)
				{
					position.x -= matrix[0] / sqrt(matrix[0] * matrix[0] + matrix[6] * matrix[6] + 0.01f) / 10.0f;
					position.z -= matrix[6] / sqrt(matrix[0] * matrix[0] + matrix[6] * matrix[6] + 0.01f) / 10.0f;
				}

				if (event.key.code == Keyboard::Q)
					position.y += 1.0f / 10.0f;

				if (event.key.code == Keyboard::E)
					position.y -= 1.0f / 10.0f;

				shader.setUniform("position", position);
			}

			if (event.type == Event::MouseMoved)
			{
				int mouse_pos[2] = { 
					event.mouseMove.x - resolution.x / 2, 
					event.mouseMove.y - resolution.y / 2 
				};
				mouse_x += mouse_pos[0];
				mouse_y += mouse_pos[1];
				float angle_x = rad(mouse_x / 15);
				float angle_y = rad(mouse_y / 15);
				float rotate_x[9] = {
					cos(-angle_x), 0.0f, -sin(-angle_x),
					0.0f, 1.0f, 0.0f,
					sin(-angle_x), 0.0f, cos(-angle_x)
				};
				float rotate_y[9] = {
					1.0f, 0.0f, 0.0f,
					0.0f, cos(angle_y), -sin(angle_y),
					0.0f, sin(angle_y), cos(angle_y)
				};
				multipleMat3f(rotate_x, rotate_y, matrix);
				view = Glsl::Mat3(matrix);
				shader.setUniform("view", view);
				Mouse::setPosition(Vector2i(resolution.x / 2, resolution.y / 2), window);
			}
		}
		window.clear();
		texture.draw(sprite, &shader);
		window.draw(sprite);
		window.display();
	}

	delete[] matrix;

	return 0;
}