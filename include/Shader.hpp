#pragma once

#include <glad/glad.h>
#include <iostream>
#include <fstream>
#include <unordered_map>

class Shader {
    private:
        unsigned int m_rendererID;
        std::unordered_map<std::string, int> m_uniformLocationCache;
    public:
        Shader() {}
        ~Shader() {}

        void Bind() const;
        void Unbind() const;

        unsigned int CompileShader(unsigned int type, const std::string& source);
        std::string ParseShader(const std::string& filepath);
        void CreateShaderProgram(const std::string& vertexShader, const std::string& fragmentShader);

        int GetUniformLocation(const std::string& name);
        void SetUniform1f(const std::string& name, float x);
        void SetUniform1i(const std::string& name, int x);
};