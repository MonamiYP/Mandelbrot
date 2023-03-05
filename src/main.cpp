#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include <fstream>
#include <cmath>

#include "Shader.hpp"
#include "Renderer.hpp"
#include "VertexBuffer.hpp"
#include "VertexBufferLayout.hpp"
#include "IndexBuffer.hpp"
#include "VertexArray.hpp"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void processInput(GLFWwindow* window);

float cameraPosx = 0.0f;
float cameraPosy = 0.0f;
float scale = 1;
float speed = 0.01f;
float maxIteration = 50;

int main() {
    if (!glfwInit())
        return -1;
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

    GLFWwindow* window;
    window = glfwCreateWindow(640, 480, "This is a window", NULL, NULL);
    if (!window) {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    float rect_vertex[] = {
        -1.0f, -1.0f, 0.0f, // bottom left
        -1.0f, 1.0f, 0.0f, // top left
        1.0f, 1.0f, 0.0f, // top right
        1.0f, -1.0f, 0.0f  // bottom right
    };
    unsigned int rect_indices[] = {
        0, 1, 2,
        2, 3, 0
    };

    VertexArray VAO;
    VertexBuffer VBO(rect_vertex, sizeof(rect_vertex));
    VertexBufferLayout layout;
    layout.AddAttribute(3);
    VAO.AddBuffer(VBO, layout);

    IndexBuffer IBO(rect_indices, 6);

    Shader shader;

    std::string vertex_source = shader.ParseShader("res/Vertex.shader");
    std::string fragment_source = shader.ParseShader("res/Fragment.shader");
    shader.CreateShaderProgram(vertex_source, fragment_source);
    shader.Bind();

    Renderer renderer;
    while (!glfwWindowShouldClose(window)) {
        processInput(window);

        renderer.Clear();

        glUniform2f(shader.GetUniformLocation("u_screenSize"), 640, 480);
        shader.SetUniform1i("u_maxIteration", maxIteration);
        glUniform2f(shader.GetUniformLocation("u_xLim"), 
            -2.0f * scale + cameraPosx,
            1.0f * scale + cameraPosx);
        glUniform2f(shader.GetUniformLocation("u_yLim"),
            -1.0f * scale + cameraPosy,
            1.0f * scale + cameraPosy);

        renderer.Draw(VAO, IBO, shader);
        
        glfwSwapBuffers(window); // Double buffer for rendering, front buffer contains final output while rendering happens on the back. Then it is swapped
        glfwPollEvents(); // Checks if any events are triggered
    }

    glfwTerminate();
}

void framebuffer_size_callback(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

void processInput(GLFWwindow* window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        cameraPosy += speed;
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        cameraPosy -= speed;
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        cameraPosx -= speed;
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        cameraPosx += speed;
    if (glfwGetKey(window, GLFW_KEY_R) == GLFW_PRESS)
        scale -= speed;
    if (glfwGetKey(window, GLFW_KEY_F) == GLFW_PRESS)
        scale += speed;
    if (glfwGetKey(window, GLFW_KEY_T) == GLFW_PRESS)
        if (maxIteration > 0) { --maxIteration; }
    if (glfwGetKey(window, GLFW_KEY_G) == GLFW_PRESS)
        if (maxIteration < 200) { ++maxIteration; }
}