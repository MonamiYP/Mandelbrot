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

void processInput(GLFWwindow* window);

float cameraPosx = 0.0f;
float cameraPosy = 0.0f;
float cameraPosz = 1.0f;
float speed = 0.01f;
float maxIteration = 50;

int frameBuffer_width = 640;
int frameBuffer_height = 480;

void framebuffer_size_callback(GLFWwindow * window, int width, int height);

Shader shader;

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

    std::string vertex_source = shader.ParseShader("res/Vertex.shader");
    std::string fragment_source = shader.ParseShader("res/Fragment.shader");
    shader.CreateShaderProgram(vertex_source, fragment_source);
    shader.Bind();

    glfwGetFramebufferSize(window, &frameBuffer_width, &frameBuffer_height);
    glUniform2f(shader.GetUniformLocation("u_screenSize"), frameBuffer_width, frameBuffer_height);

    Renderer renderer;
    while (!glfwWindowShouldClose(window)) {
        processInput(window);

        renderer.Clear();
        
        shader.SetUniform1i("u_maxIteration", maxIteration);
        glUniform3f(shader.GetUniformLocation("u_cameraPos"), cameraPosx, cameraPosy, cameraPosz);

        renderer.Draw(VAO, IBO, shader);
        
        glfwSwapBuffers(window); // Double buffer for rendering, front buffer contains final output while rendering happens on the back. Then it is swapped
        glfwPollEvents(); // Checks if any events are triggered
    }

    glfwTerminate();
}

void framebuffer_size_callback(GLFWwindow * window, int width, int height) {
    glUniform2f(shader.GetUniformLocation("u_screenSize"), width, height);
    glViewport(0, 0, width, height);
}

void processInput(GLFWwindow* window) {
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
        cameraPosy += speed * pow(10, cameraPosz);
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
        cameraPosy -= speed * pow(10, cameraPosz);
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        cameraPosx -= speed * pow(10, cameraPosz);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        cameraPosx += speed * pow(10, cameraPosz);
    if (glfwGetKey(window, GLFW_KEY_R) == GLFW_PRESS)
        cameraPosz -= speed;
    if (glfwGetKey(window, GLFW_KEY_F) == GLFW_PRESS)
        cameraPosz += speed;
    if (glfwGetKey(window, GLFW_KEY_T) == GLFW_PRESS)
        if (maxIteration > 0) { --maxIteration; }
    if (glfwGetKey(window, GLFW_KEY_G) == GLFW_PRESS)
        if (maxIteration < 500) { ++maxIteration; }
}