package hello_triangle

import "core:fmt"

import gl "vendor:OpenGL"
import "vendor:glfw"

main :: proc() {

    // ====================== //
    // === INITIALIZATION === //
    // ====================== //

    glfw.Init()
    
    // create a window with glfw
    window_width  : i32 = 1600 
    window_height : i32 = 900
    window := glfw.CreateWindow(window_width, window_height, "Hello Triangle", nil, nil)
    if window == nil {
        glfw.Terminate()
        return
    }
    
    glfw.MakeContextCurrent(window)
    
    // load OpenGL
    gl.load_up_to(4, 6, glfw.gl_set_proc_address)

    // give OpenGL infor about the area it can draw to
    gl.Viewport(0, 0, window_width, window_height)

    // set window resize function
    glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    // =============== // 
    // === SHADERS === //
    // =============== //
    
    success : i32
    infoLog : [512]u8

    // vertex shader binding and compiling
    vertexShaderSource : cstring =  "#version 460\nlayout (location = 0) in vec3 aPos;\nvoid main()\n{\ngl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n};"
    vertexShader : u32 // shader ID
    vertexShader = gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vertexShader, 1, cast([^]cstring)&vertexShaderSource, nil)
    gl.CompileShader(vertexShader)
    gl.GetShaderiv(vertexShader, gl.COMPILE_STATUS, &success)
    fmt.println("Vertex Shader success?", success)

    // fragment shader binding and compiling
    fragmentShaderSource : cstring = "#version 460\nout vec4 FragColor;\nvoid main(){FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);}" 
    fragmentShader : u32
    fragmentShader = gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fragmentShader, 1, cast([^]cstring)&fragmentShaderSource, nil)
    gl.CompileShader(fragmentShader)
    gl.GetShaderiv(fragmentShader, gl.COMPILE_STATUS, &success)
    fmt.println("Fragment Shader success?", success)

    // shader program
    shaderProgram : u32
    shaderProgram = gl.CreateProgram()
    gl.AttachShader(shaderProgram, vertexShader)
    gl.AttachShader(shaderProgram, fragmentShader)
    gl.LinkProgram(shaderProgram)
    gl.GetProgramiv(shaderProgram, gl.LINK_STATUS, &success)
    fmt.println("Shader success?", success)
    
    gl.DeleteShader(vertexShader)
    gl.DeleteShader(fragmentShader)

    // ======================= //
    // === OBJECTS TO DRAW === // 
    // ======================= //

    /*
    vertices := []f32{
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
         0.0,  0.5, 0.0,
    } 
    */
    vertices := []f32{
        -0.5, -0.5, 0.0,
         0.5, -0.5, 0.0,
        -0.5,  0.5, 0.0,
         0.5,  0.5, 0.0,
    }

    indices := []u32{
        0, 1, 2,
        1, 2, 3,
    }

    // Vertex Array Object
    VAO : u32
    gl.GenVertexArrays(1, &VAO)
    gl.BindVertexArray(VAO)

    // Vertex Buffer Object
    VBO : u32
    gl.GenBuffers(1, &VBO)
    gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
    gl.BufferData(gl.ARRAY_BUFFER, size_of(f32) * len(vertices), raw_data(vertices), gl.STATIC_DRAW)
    
    // Element Buffer Object
    EBO : u32
    gl.GenBuffers(1, &EBO)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, size_of(u32) * len(indices), raw_data(indices), gl.STATIC_DRAW)

    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
    gl.EnableVertexAttribArray(0)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindVertexArray(0)
    
    // ================= //
    // === RENDERING === //
    // ================= //

    // main rendering loop
    for !glfw.WindowShouldClose(window) {
        
        // basic OpenGL action
        gl.ClearColor(1.,1.,1.,0.5)    // set state
        gl.Clear(gl.COLOR_BUFFER_BIT) // use state
        
        gl.UseProgram(shaderProgram)
        gl.BindVertexArray(VAO)
        // gl.DrawArrays(gl.TRIANGLES, 0, 3)
        
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)

        glfw.SwapBuffers(window) // swap color buffer
        glfw.PollEvents()        // check for triggered events
    }

    // =================== //
    // === TERMINATION === //
    // =================== //

    // clean up OpenGL stuff
    gl.DeleteVertexArrays(1, &VAO)
    gl.DeleteBuffers(1, &VBO)
    gl.DeleteBuffers(1, &EBO)
    gl.DeleteProgram(shaderProgram)

    // close the window
    glfw.Terminate()

    return
}

framebuffer_size_callback :: proc "c" (window:glfw.WindowHandle, width:i32, height:i32) {
    // tells OpenGL the size of its drawing area after a resize event
    gl.Viewport(0, 0, width, height)
}