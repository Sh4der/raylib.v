module raylibv

//*************************************************  rlgl v4.5 - A multi-OpenGL abstraction layer with an immediate-mode style API
//**  DESCRIPTION:
//*      An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
//*      that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
//**  ADDITIONAL NOTES:
//*      When choosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
//*      initialized on rlglInit() to accumulate vertex data.
//**      When an internal state change is required all the stored vertex data is renderer in batch,
//*      additionally, rlDrawRenderBatchActive() could be called to force flushing of the batch.
//**      Some resources are also loaded for convenience, here the complete list:
//*         - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
//*         - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
//*         - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
//**      Internal buffer (and resources) must be manually unloaded calling rlglClose().
//**  CONFIGURATION:
//*      #define GRAPHICS_API_OPENGL_11
//*      #define GRAPHICS_API_OPENGL_21
//*      #define GRAPHICS_API_OPENGL_33
//*      #define GRAPHICS_API_OPENGL_43
//*      #define GRAPHICS_API_OPENGL_ES2
//*      #define GRAPHICS_API_OPENGL_ES3
//*          Use selected OpenGL graphics backend, should be supported by platform
//*          Those preprocessor defines are only used on rlgl module, if OpenGL version is
//*          required by any other module, use rlGetVersion() to check it
//**      #define RLGL_IMPLEMENTATION
//*          Generates the implementation of the library into the included file.
//*          If not defined, the library is in header only mode and can be included in other headers
//*          or source files without problems. But only ONE file should hold the implementation.
//**      #define RLGL_RENDER_TEXTURES_HINT
//*          Enable framebuffer objects (fbo) support (enabled by default)
//*          Some GPUs could not support them despite the OpenGL version
//**      #define RLGL_SHOW_GL_DETAILS_INFO
//*          Show OpenGL extensions and capabilities detailed logs on init
//**      #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
//*          Enable debug context (only available on OpenGL 4.3)
//**      rlgl capabilities could be customized just defining some internal
//*      values before library inclusion (default values listed):
//**      #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
//*      #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
//*      #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
//*      #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
//**      #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
//*      #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
//*      #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
//*      #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
//**      When loading a shader, the following vertex attributes and uniform
//*      location names are tried to be set automatically:
//**      #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Bound by default to shader location: 0
//*      #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Bound by default to shader location: 1
//*      #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Bound by default to shader location: 2
//*      #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Bound by default to shader location: 3
//*      #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Bound by default to shader location: 4
//*      #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Bound by default to shader location: 5
//*      #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
//*      #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
//*      #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
//*      #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
//*      #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
//*      #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
//*      #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
//*      #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
//*      #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
//**  DEPENDENCIES:
//*     - OpenGL libraries (depending on platform and OpenGL version selected)
//*     - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
//***  LICENSE: zlib/libpng
//**  Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
//**  This software is provided "as-is", without any express or implied warranty. In no event
//*  will the authors be held liable for any damages arising from the use of this software.
//**  Permission is granted to anyone to use this software for any purpose, including commercial
//*  applications, and to alter it and redistribute it freely, subject to the following restrictions:
//**    1. The origin of this software must not be misrepresented; you must not claim that you
//*    wrote the original software. If you use this software in a product, an acknowledgment
//*    in the product documentation would be appreciated but is not required.
//**    2. Altered source versions must be plainly marked as such, and must not be misrepresented
//*    as being the original software.
//**    3. This notice may not be removed or altered from any source distribution.
//************************************************/
//
//#ifndef RLGL_H
//#define RLGL_H
//
//#define RLGL_VERSION  "4.5"
//
//// Function specifiers in case library is build/used as a shared library (Windows)
//// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
//#if defined(_WIN32)
//    #if defined(BUILD_LIBTYPE_SHARED)
//        #define RLAPI __declspec(dllexport)     // We are building the library as a Win32 shared library (.dll)
//    #elif defined(USE_LIBTYPE_SHARED)
//        #define RLAPI __declspec(dllimport)     // We are using the library as a Win32 shared library (.dll)
//    #endif
//#endif
//
//// Function specifiers definition
//#ifndef RLAPI
//    #define RLAPI       // Functions defined as 'extern' by default (implicit specifiers)
//#endif
//
//// Support TRACELOG macros
//#ifndef TRACELOG
//    #define TRACELOG(level, ...) (void)0
//    #define TRACELOGD(...) (void)0
//#endif
//
//// Allow custom memory allocators
//#ifndef RL_MALLOC
//    #define RL_MALLOC(sz)     malloc(sz)
//#endif
//#ifndef RL_CALLOC
//    #define RL_CALLOC(n,sz)   calloc(n,sz)
//#endif
//#ifndef RL_REALLOC
//    #define RL_REALLOC(n,sz)  realloc(n,sz)
//#endif
//#ifndef RL_FREE
//    #define RL_FREE(p)        free(p)
//#endif
//
//// Security check in case no GRAPHICS_API_OPENGL_*defined
//#if !defined(GRAPHICS_API_OPENGL_11) && \
//    !defined(GRAPHICS_API_OPENGL_21) && \
//    !defined(GRAPHICS_API_OPENGL_33) && \
//    !defined(GRAPHICS_API_OPENGL_43) && \
//    !defined(GRAPHICS_API_OPENGL_ES2) && \
//    !defined(GRAPHICS_API_OPENGL_ES3)
//        #define GRAPHICS_API_OPENGL_33
//#endif
//
//// Security check in case multiple GRAPHICS_API_OPENGL_*defined
//#if defined(GRAPHICS_API_OPENGL_11)
//    #if defined(GRAPHICS_API_OPENGL_21)
//        #undef GRAPHICS_API_OPENGL_21
//    #endif
//    #if defined(GRAPHICS_API_OPENGL_33)
//        #undef GRAPHICS_API_OPENGL_33
//    #endif
//    #if defined(GRAPHICS_API_OPENGL_43)
//        #undef GRAPHICS_API_OPENGL_43
//    #endif
//    #if defined(GRAPHICS_API_OPENGL_ES2)
//        #undef GRAPHICS_API_OPENGL_ES2
//    #endif
//#endif
//
//// OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
//// WARNING: Specific parts are checked with #if defines
//#if defined(GRAPHICS_API_OPENGL_21)
//    #define GRAPHICS_API_OPENGL_33
//#endif
//
//// OpenGL 4.3 uses OpenGL 3.3 Core functionality
//#if defined(GRAPHICS_API_OPENGL_43)
//    #define GRAPHICS_API_OPENGL_33
//#endif
//
//// OpenGL ES 3.0 uses OpenGL ES 2.0 functionality (and more)
//#if defined(GRAPHICS_API_OPENGL_ES3)
//    #define GRAPHICS_API_OPENGL_ES2
//#endif
//
//// Support framebuffer objects by default
//// NOTE: Some driver implementation do not support it, despite they should
//#define RLGL_RENDER_TEXTURES_HINT
//
////----------------------------------------------------------------------------------
//// Defines and Macros
////----------------------------------------------------------------------------------
//
//// Default internal render batch elements limits
//#ifndef RL_DEFAULT_BATCH_BUFFER_ELEMENTS
//    #if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
//        // This is the maximum amount of elements (quads) per batch
//        // NOTE: Be careful with text, every letter maps to a quad
//        #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS  8192
//    #endif
//    #if defined(GRAPHICS_API_OPENGL_ES2)
//        // We reduce memory sizes for embedded systems (RPI and HTML5)
//        // NOTE: On HTML5 (emscripten) this is allocated on heap,
//        // by default it's only 16MB!...just take care...
//        #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS  2048
//    #endif
//#endif
//#ifndef RL_DEFAULT_BATCH_BUFFERS
//    #define RL_DEFAULT_BATCH_BUFFERS                 1      // Default number of batch buffers (multi-buffering)
//#endif
//#ifndef RL_DEFAULT_BATCH_DRAWCALLS
//    #define RL_DEFAULT_BATCH_DRAWCALLS             256      // Default number of batch draw calls (by state changes: mode, texture)
//#endif
//#ifndef RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS
//    #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS       4      // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
//#endif
//
//// Internal Matrix stack
//#ifndef RL_MAX_MATRIX_STACK_SIZE
//    #define RL_MAX_MATRIX_STACK_SIZE                32      // Maximum size of Matrix stack
//#endif
//
//// Shader limits
//#ifndef RL_MAX_SHADER_LOCATIONS
//    #define RL_MAX_SHADER_LOCATIONS                 32      // Maximum number of shader locations supported
//#endif
//
//// Projection matrix culling
//#ifndef RL_CULL_DISTANCE_NEAR
//    #define RL_CULL_DISTANCE_NEAR                 0.01      // Default near cull distance
//#endif
//#ifndef RL_CULL_DISTANCE_FAR
//    #define RL_CULL_DISTANCE_FAR                1000.0      // Default far cull distance
//#endif
//
//// Texture parameters (equivalent to OpenGL defines)
//#define RL_TEXTURE_WRAP_S                       0x2802      // GL_TEXTURE_WRAP_S
//#define RL_TEXTURE_WRAP_T                       0x2803      // GL_TEXTURE_WRAP_T
//#define RL_TEXTURE_MAG_FILTER                   0x2800      // GL_TEXTURE_MAG_FILTER
//#define RL_TEXTURE_MIN_FILTER                   0x2801      // GL_TEXTURE_MIN_FILTER
//
//#define RL_TEXTURE_FILTER_NEAREST               0x2600      // GL_NEAREST
//#define RL_TEXTURE_FILTER_LINEAR                0x2601      // GL_LINEAR
//#define RL_TEXTURE_FILTER_MIP_NEAREST           0x2700      // GL_NEAREST_MIPMAP_NEAREST
//#define RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR    0x2702      // GL_NEAREST_MIPMAP_LINEAR
//#define RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST    0x2701      // GL_LINEAR_MIPMAP_NEAREST
//#define RL_TEXTURE_FILTER_MIP_LINEAR            0x2703      // GL_LINEAR_MIPMAP_LINEAR
//#define RL_TEXTURE_FILTER_ANISOTROPIC           0x3000      // Anisotropic filter (custom identifier)
//#define RL_TEXTURE_MIPMAP_BIAS_RATIO            0x4000      // Texture mipmap bias, percentage ratio (custom identifier)
//
//#define RL_TEXTURE_WRAP_REPEAT                  0x2901      // GL_REPEAT
//#define RL_TEXTURE_WRAP_CLAMP                   0x812F      // GL_CLAMP_TO_EDGE
//#define RL_TEXTURE_WRAP_MIRROR_REPEAT           0x8370      // GL_MIRRORED_REPEAT
//#define RL_TEXTURE_WRAP_MIRROR_CLAMP            0x8742      // GL_MIRROR_CLAMP_EXT
//
//// Matrix modes (equivalent to OpenGL)
//#define RL_MODELVIEW                            0x1700      // GL_MODELVIEW
//#define RL_PROJECTION                           0x1701      // GL_PROJECTION
//#define RL_TEXTURE                              0x1702      // GL_TEXTURE
//
//// Primitive assembly draw modes
//#define RL_LINES                                0x0001      // GL_LINES
//#define RL_TRIANGLES                            0x0004      // GL_TRIANGLES
//#define RL_QUADS                                0x0007      // GL_QUADS
//
//// GL equivalent data types
//#define RL_UNSIGNED_BYTE                        0x1401      // GL_UNSIGNED_BYTE
//#define RL_FLOAT                                0x1406      // GL_FLOAT
pub const rl_unsigned_byte = 0x1403      // GL_UNSIGNED_SHORT
pub const rl_unsigned_short = 0x1403      // GL_UNSIGNED_SHORT
pub const rl_unsigned_int = 0x1405      // GL_UNSIGNED_INT
pub const rl_float = 0x1406      // GL_FLOAT
//
//// GL buffer usage hint
//#define RL_STREAM_DRAW                          0x88E0      // GL_STREAM_DRAW
//#define RL_STREAM_READ                          0x88E1      // GL_STREAM_READ
//#define RL_STREAM_COPY                          0x88E2      // GL_STREAM_COPY
//#define RL_STATIC_DRAW                          0x88E4      // GL_STATIC_DRAW
//#define RL_STATIC_READ                          0x88E5      // GL_STATIC_READ
//#define RL_STATIC_COPY                          0x88E6      // GL_STATIC_COPY
//#define RL_DYNAMIC_DRAW                         0x88E8      // GL_DYNAMIC_DRAW
//#define RL_DYNAMIC_READ                         0x88E9      // GL_DYNAMIC_READ
//#define RL_DYNAMIC_COPY                         0x88EA      // GL_DYNAMIC_COPY
//
//// GL Shader type
//#define RL_FRAGMENT_SHADER                      0x8B30      // GL_FRAGMENT_SHADER
//#define RL_VERTEX_SHADER                        0x8B31      // GL_VERTEX_SHADER
//#define RL_COMPUTE_SHADER                       0x91B9      // GL_COMPUTE_SHADER
//
//// GL blending factors
//#define RL_ZERO                                 0           // GL_ZERO
//#define RL_ONE                                  1           // GL_ONE
//#define RL_SRC_COLOR                            0x0300      // GL_SRC_COLOR
//#define RL_ONE_MINUS_SRC_COLOR                  0x0301      // GL_ONE_MINUS_SRC_COLOR
//#define RL_SRC_ALPHA                            0x0302      // GL_SRC_ALPHA
//#define RL_ONE_MINUS_SRC_ALPHA                  0x0303      // GL_ONE_MINUS_SRC_ALPHA
//#define RL_DST_ALPHA                            0x0304      // GL_DST_ALPHA
//#define RL_ONE_MINUS_DST_ALPHA                  0x0305      // GL_ONE_MINUS_DST_ALPHA
//#define RL_DST_COLOR                            0x0306      // GL_DST_COLOR
//#define RL_ONE_MINUS_DST_COLOR                  0x0307      // GL_ONE_MINUS_DST_COLOR
//#define RL_SRC_ALPHA_SATURATE                   0x0308      // GL_SRC_ALPHA_SATURATE
//#define RL_CONSTANT_COLOR                       0x8001      // GL_CONSTANT_COLOR
//#define RL_ONE_MINUS_CONSTANT_COLOR             0x8002      // GL_ONE_MINUS_CONSTANT_COLOR
//#define RL_CONSTANT_ALPHA                       0x8003      // GL_CONSTANT_ALPHA
//#define RL_ONE_MINUS_CONSTANT_ALPHA             0x8004      // GL_ONE_MINUS_CONSTANT_ALPHA
//
//// GL blending functions/equations
//#define RL_FUNC_ADD                             0x8006      // GL_FUNC_ADD
//#define RL_MIN                                  0x8007      // GL_MIN
//#define RL_MAX                                  0x8008      // GL_MAX
//#define RL_FUNC_SUBTRACT                        0x800A      // GL_FUNC_SUBTRACT
//#define RL_FUNC_REVERSE_SUBTRACT                0x800B      // GL_FUNC_REVERSE_SUBTRACT
//#define RL_BLEND_EQUATION                       0x8009      // GL_BLEND_EQUATION
//#define RL_BLEND_EQUATION_RGB                   0x8009      // GL_BLEND_EQUATION_RGB   // (Same as BLEND_EQUATION)
//#define RL_BLEND_EQUATION_ALPHA                 0x883D      // GL_BLEND_EQUATION_ALPHA
//#define RL_BLEND_DST_RGB                        0x80C8      // GL_BLEND_DST_RGB
//#define RL_BLEND_SRC_RGB                        0x80C9      // GL_BLEND_SRC_RGB
//#define RL_BLEND_DST_ALPHA                      0x80CA      // GL_BLEND_DST_ALPHA
//#define RL_BLEND_SRC_ALPHA                      0x80CB      // GL_BLEND_SRC_ALPHA
//#define RL_BLEND_COLOR                          0x8005      // GL_BLEND_COLOR
//
//
////----------------------------------------------------------------------------------
//// Types and Structures Definition
////----------------------------------------------------------------------------------
//#if (defined(__STDC__) && __STDC_VERSION__ >= 199901L) || (defined(_MSC_VER) && _MSC_VER >= 1800)
//    #include <stdbool.h>
//#elif !defined(__cplusplus) && !defined(bool) && !defined(RL_BOOL_TYPE)
//    // Boolean type
//typedef pub enum bool { false = 0, true = !false } bool;
//#endif
//
//#if !defined(RL_MATRIX_TYPE)
//// Matrix, 4x4 components, column major, OpenGL style, right handed
//typedef struct Matrix {
//    float m0, m4, m8, m12;      // Matrix first row (4 components)
//    float m1, m5, m9, m13;      // Matrix second row (4 components)
//    float m2, m6, m10, m14;     // Matrix third row (4 components)
//    float m3, m7, m11, m15;     // Matrix fourth row (4 components)
//} Matrix;
//#define RL_MATRIX_TYPE
//#endif
//
//// Dynamic vertex buffers (position + texcoords + colors + indices arrays)
//typedef struct rlVertexBuffer {
//    int elementCount;           // Number of elements in the buffer (QUADS)
//
//    float *ertices;            // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
//    float *excoords;           // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
//    unsigned char *olors;      // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
//#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
//    unsigned int *ndices;      // Vertex indices (in case vertex data comes indexed) (6 indices per quad)
//#endif
//#if defined(GRAPHICS_API_OPENGL_ES2)
//    unsigned short *ndices;    // Vertex indices (in case vertex data comes indexed) (6 indices per quad)
//#endif
//    unsigned int vaoId;         // OpenGL Vertex Array Object id
//    unsigned int vboId[4];      // OpenGL Vertex Buffer Objects id (4 types of vertex data)
//} rlVertexBuffer;
//
//// Draw call type
//// NOTE: Only texture changes register a new draw, other state-change-related elements are not
//// used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
//// of those state-change happens (this is done in core module)
//typedef struct rlDrawCall {
//    int mode;                   // Drawing mode: LINES, TRIANGLES, QUADS
//    int vertexCount;            // Number of vertex of the draw
//    int vertexAlignment;        // Number of vertex required for index alignment (LINES, TRIANGLES)
//    //unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
//    //unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShaderId
//    unsigned int textureId;     // Texture id to be used on the draw -> Use to create new draw call if changes
//
//    //Matrix projection;        // Projection matrix for this draw -> Using RLGL.projection by default
//    //Matrix modelview;         // Modelview matrix for this draw -> Using RLGL.modelview by default
//} rlDrawCall;
//
//// rlRenderBatch type
//typedef struct rlRenderBatch {
//    int bufferCount;            // Number of vertex buffers (multi-buffering support)
//    int currentBuffer;          // Current buffer tracking in case of multi-buffering
//    rlVertexBuffer *ertexBuffer; // Dynamic buffer(s) for vertex data
//
//    rlDrawCall *raws;          // Draw calls array, depends on textureId
//    int drawCounter;            // Draw calls counter
//    float currentDepth;         // Current depth value for next draw
//} rlRenderBatch;
//
//// OpenGL version
//typedef pub enum {
//    RL_OPENGL_11 = 1,           // OpenGL 1.1
//    RL_OPENGL_21,               // OpenGL 2.1 (GLSL 120)
//    RL_OPENGL_33,               // OpenGL 3.3 (GLSL 330)
//    RL_OPENGL_43,               // OpenGL 4.3 (using GLSL 330)
//    RL_OPENGL_ES_20,            // OpenGL ES 2.0 (GLSL 100)
//    RL_OPENGL_ES_30             // OpenGL ES 3.0 (GLSL 300 es)
//} rlGlVersion;
//
//// Trace log level
//// NOTE: Organized by priority level
//typedef pub enum {
//    RL_LOG_ALL = 0,             // Display all logs
//    RL_LOG_TRACE,               // Trace logging, intended for internal use only
//    RL_LOG_DEBUG,               // Debug logging, used for internal debugging, it should be disabled on release builds
//    RL_LOG_INFO,                // Info logging, used for program execution info
//    RL_LOG_WARNING,             // Warning logging, used on recoverable failures
//    RL_LOG_ERROR,               // Error logging, used on unrecoverable failures
//    RL_LOG_FATAL,               // Fatal logging, used to abort program: exit(EXIT_FAILURE)
//    RL_LOG_NONE                 // Disable logging
//} rlTraceLogLevel;
//
//// Texture pixel formats
//// NOTE: Support depends on OpenGL version
//typedef pub enum {
//    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1,     // 8 bit per pixel (no alpha)
//    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA,        // 8* bpp (2 channels)
//    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5,            // 16 bpp
//    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8,            // 24 bpp
//    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1,          // 16 bpp (1 bit alpha)
//    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4,          // 16 bpp (4 bit alpha)
//    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8,          // 32 bpp
//    RL_PIXELFORMAT_UNCOMPRESSED_R32,               // 32 bpp (1 channel - float)
//    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32,         // 32* bpp (3 channels - float)
//    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32,      // 32* bpp (4 channels - float)
//    RL_PIXELFORMAT_UNCOMPRESSED_R16,               // 16 bpp (1 channel - half float)
//    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16,         // 16* bpp (3 channels - half float)
//    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16,      // 16* bpp (4 channels - half float)
//    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB,            // 4 bpp (no alpha)
//    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA,           // 4 bpp (1 bit alpha)
//    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA,           // 8 bpp
//    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA,           // 8 bpp
//    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB,            // 4 bpp
//    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB,            // 4 bpp
//    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA,       // 8 bpp
//    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB,            // 4 bpp
//    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA,           // 4 bpp
//    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA,       // 8 bpp
//    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA        // 2 bpp
//} rlPixelFormat;
//
//// Texture parameters: filter mode
//// NOTE 1: Filtering considers mipmaps if available in the texture
//// NOTE 2: Filter is accordingly set for minification and magnification
//typedef pub enum {
//    RL_TEXTURE_FILTER_POINT = 0,        // No filter, just pixel approximation
//    RL_TEXTURE_FILTER_BILINEAR,         // Linear filtering
//    RL_TEXTURE_FILTER_TRILINEAR,        // Trilinear filtering (linear with mipmaps)
//    RL_TEXTURE_FILTER_ANISOTROPIC_4X,   // Anisotropic filtering 4x
//    RL_TEXTURE_FILTER_ANISOTROPIC_8X,   // Anisotropic filtering 8x
//    RL_TEXTURE_FILTER_ANISOTROPIC_16X,  // Anisotropic filtering 16x
//} rlTextureFilter;
//
//// Color blending modes (pre-defined)
//typedef pub enum {
//    RL_BLEND_ALPHA = 0,                 // Blend textures considering alpha (default)
//    RL_BLEND_ADDITIVE,                  // Blend textures adding colors
//    RL_BLEND_MULTIPLIED,                // Blend textures multiplying colors
//    RL_BLEND_ADD_COLORS,                // Blend textures adding colors (alternative)
//    RL_BLEND_SUBTRACT_COLORS,           // Blend textures subtracting colors (alternative)
//    RL_BLEND_ALPHA_PREMULTIPLY,         // Blend premultiplied textures considering alpha
//    RL_BLEND_CUSTOM,                    // Blend textures using custom src/dst factors (use rlSetBlendFactors())
//    RL_BLEND_CUSTOM_SEPARATE            // Blend textures using custom src/dst factors (use rlSetBlendFactorsSeparate())
//} rlBlendMode;
//
//// Shader location point type
//typedef pub enum {
//    RL_SHADER_LOC_VERTEX_POSITION = 0,  // Shader location: vertex attribute: position
//    RL_SHADER_LOC_VERTEX_TEXCOORD01,    // Shader location: vertex attribute: texcoord01
//    RL_SHADER_LOC_VERTEX_TEXCOORD02,    // Shader location: vertex attribute: texcoord02
//    RL_SHADER_LOC_VERTEX_NORMAL,        // Shader location: vertex attribute: normal
//    RL_SHADER_LOC_VERTEX_TANGENT,       // Shader location: vertex attribute: tangent
//    RL_SHADER_LOC_VERTEX_COLOR,         // Shader location: vertex attribute: color
//    RL_SHADER_LOC_MATRIX_MVP,           // Shader location: matrix uniform: model-view-projection
//    RL_SHADER_LOC_MATRIX_VIEW,          // Shader location: matrix uniform: view (camera transform)
//    RL_SHADER_LOC_MATRIX_PROJECTION,    // Shader location: matrix uniform: projection
//    RL_SHADER_LOC_MATRIX_MODEL,         // Shader location: matrix uniform: model (transform)
//    RL_SHADER_LOC_MATRIX_NORMAL,        // Shader location: matrix uniform: normal
//    RL_SHADER_LOC_VECTOR_VIEW,          // Shader location: vector uniform: view
//    RL_SHADER_LOC_COLOR_DIFFUSE,        // Shader location: vector uniform: diffuse color
//    RL_SHADER_LOC_COLOR_SPECULAR,       // Shader location: vector uniform: specular color
//    RL_SHADER_LOC_COLOR_AMBIENT,        // Shader location: vector uniform: ambient color
//    RL_SHADER_LOC_MAP_ALBEDO,           // Shader location: sampler2d texture: albedo (same as: RL_SHADER_LOC_MAP_DIFFUSE)
//    RL_SHADER_LOC_MAP_METALNESS,        // Shader location: sampler2d texture: metalness (same as: RL_SHADER_LOC_MAP_SPECULAR)
//    RL_SHADER_LOC_MAP_NORMAL,           // Shader location: sampler2d texture: normal
//    RL_SHADER_LOC_MAP_ROUGHNESS,        // Shader location: sampler2d texture: roughness
//    RL_SHADER_LOC_MAP_OCCLUSION,        // Shader location: sampler2d texture: occlusion
//    RL_SHADER_LOC_MAP_EMISSION,         // Shader location: sampler2d texture: emission
//    RL_SHADER_LOC_MAP_HEIGHT,           // Shader location: sampler2d texture: height
//    RL_SHADER_LOC_MAP_CUBEMAP,          // Shader location: samplerCube texture: cubemap
//    RL_SHADER_LOC_MAP_IRRADIANCE,       // Shader location: samplerCube texture: irradiance
//    RL_SHADER_LOC_MAP_PREFILTER,        // Shader location: samplerCube texture: prefilter
//    RL_SHADER_LOC_MAP_BRDF              // Shader location: sampler2d texture: brdf
//} rlShaderLocationIndex;
//
//#define RL_SHADER_LOC_MAP_DIFFUSE       RL_SHADER_LOC_MAP_ALBEDO
//#define RL_SHADER_LOC_MAP_SPECULAR      RL_SHADER_LOC_MAP_METALNESS
//
//// Shader uniform data type
//typedef pub enum {
//    RL_SHADER_UNIFORM_FLOAT = 0,        // Shader uniform type: float
//    RL_SHADER_UNIFORM_VEC2,             // Shader uniform type: vec2 (2 float)
//    RL_SHADER_UNIFORM_VEC3,             // Shader uniform type: vec3 (3 float)
//    RL_SHADER_UNIFORM_VEC4,             // Shader uniform type: vec4 (4 float)
//    RL_SHADER_UNIFORM_INT,              // Shader uniform type: int
//    RL_SHADER_UNIFORM_IVEC2,            // Shader uniform type: ivec2 (2 int)
//    RL_SHADER_UNIFORM_IVEC3,            // Shader uniform type: ivec3 (3 int)
//    RL_SHADER_UNIFORM_IVEC4,            // Shader uniform type: ivec4 (4 int)
//    RL_SHADER_UNIFORM_SAMPLER2D         // Shader uniform type: sampler2d
//} rlShaderUniformDataType;
//
//// Shader attribute data types
//typedef pub enum {
//    RL_SHADER_ATTRIB_FLOAT = 0,         // Shader attribute type: float
//    RL_SHADER_ATTRIB_VEC2,              // Shader attribute type: vec2 (2 float)
//    RL_SHADER_ATTRIB_VEC3,              // Shader attribute type: vec3 (3 float)
//    RL_SHADER_ATTRIB_VEC4               // Shader attribute type: vec4 (4 float)
//} rlShaderAttributeDataType;
//
//// Framebuffer attachment type
//// NOTE: By default up to 8 color channels defined, but it can be more
//typedef pub enum {
//    RL_ATTACHMENT_COLOR_CHANNEL0 = 0,       // Framebuffer attachment type: color 0
//    RL_ATTACHMENT_COLOR_CHANNEL1 = 1,       // Framebuffer attachment type: color 1
//    RL_ATTACHMENT_COLOR_CHANNEL2 = 2,       // Framebuffer attachment type: color 2
//    RL_ATTACHMENT_COLOR_CHANNEL3 = 3,       // Framebuffer attachment type: color 3
//    RL_ATTACHMENT_COLOR_CHANNEL4 = 4,       // Framebuffer attachment type: color 4
//    RL_ATTACHMENT_COLOR_CHANNEL5 = 5,       // Framebuffer attachment type: color 5
//    RL_ATTACHMENT_COLOR_CHANNEL6 = 6,       // Framebuffer attachment type: color 6
//    RL_ATTACHMENT_COLOR_CHANNEL7 = 7,       // Framebuffer attachment type: color 7
//    RL_ATTACHMENT_DEPTH = 100,              // Framebuffer attachment type: depth
//    RL_ATTACHMENT_STENCIL = 200,            // Framebuffer attachment type: stencil
//} rlFramebufferAttachType;
//
//// Framebuffer texture attachment type
//typedef pub enum {
//    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0,   // Framebuffer texture attachment type: cubemap, +X side
//    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = 1,   // Framebuffer texture attachment type: cubemap, -X side
//    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = 2,   // Framebuffer texture attachment type: cubemap, +Y side
//    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = 3,   // Framebuffer texture attachment type: cubemap, -Y side
//    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = 4,   // Framebuffer texture attachment type: cubemap, +Z side
//    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = 5,   // Framebuffer texture attachment type: cubemap, -Z side
//    RL_ATTACHMENT_TEXTURE2D = 100,          // Framebuffer texture attachment type: texture2d
//    RL_ATTACHMENT_RENDERBUFFER = 200,       // Framebuffer texture attachment type: renderbuffer
//} rlFramebufferAttachTextureType;
//
//// Face culling mode
//typedef pub enum {
//    RL_CULL_FACE_FRONT = 0,
//    RL_CULL_FACE_BACK
//} rlCullMode;
//
////------------------------------------------------------------------------------------
//// Functions Declaration - Matrix operations
////------------------------------------------------------------------------------------
//
//#if defined(__cplusplus)
//extern "C" {            // Prevents name mangling of functions
//#endif
//
//RLAPI void rlMatrixMode(int mode);                    // Choose the current matrix to be transformed
//RLAPI void rlPushMatrix(void);                        // Push the current matrix to stack
//RLAPI void rlPopMatrix(void);                         // Pop latest inserted matrix from stack
//RLAPI void rlLoadIdentity(void);                      // Reset current matrix to identity matrix
//RLAPI void rlTranslatef(float x, float y, float z);   // Multiply the current matrix by a translation matrix
//RLAPI void rlRotatef(float angle, float x, float y, float z);  // Multiply the current matrix by a rotation matrix
//RLAPI void rlScalef(float x, float y, float z);       // Multiply the current matrix by a scaling matrix
//RLAPI void rlMultMatrixf(const float *atf);                // Multiply the current matrix by another matrix
//RLAPI void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar);
//RLAPI void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar);
//RLAPI void rlViewport(int x, int y, int width, int height); // Set the viewport area
//
////------------------------------------------------------------------------------------
//// Functions Declaration - Vertex level operations
////------------------------------------------------------------------------------------
//RLAPI void rlBegin(int mode);                         // Initialize drawing mode (how to organize vertex)
//RLAPI void rlEnd(void);                               // Finish vertex providing
//RLAPI void rlVertex2i(int x, int y);                  // Define one vertex (position) - 2 int
//RLAPI void rlVertex2f(float x, float y);              // Define one vertex (position) - 2 float
//RLAPI void rlVertex3f(float x, float y, float z);     // Define one vertex (position) - 3 float
//RLAPI void rlTexCoord2f(float x, float y);            // Define one vertex (texture coordinate) - 2 float
//RLAPI void rlNormal3f(float x, float y, float z);     // Define one vertex (normal) - 3 float
//RLAPI void rlColor4ub(unsigned char r, unsigned char g, unsigned char b, unsigned char a);  // Define one vertex (color) - 4 byte
//RLAPI void rlColor3f(float x, float y, float z);          // Define one vertex (color) - 3 float
//RLAPI void rlColor4f(float x, float y, float z, float w); // Define one vertex (color) - 4 float
//
////------------------------------------------------------------------------------------
//// Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
//// NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
//// some of them are direct wrappers over OpenGL calls, some others are custom
////------------------------------------------------------------------------------------
//
//// Vertex buffers state
//RLAPI bool rlEnableVertexArray(unsigned int vaoId);     // Enable vertex array (VAO, if supported)
//RLAPI void rlDisableVertexArray(void);                  // Disable vertex array (VAO, if supported)
//RLAPI void rlEnableVertexBuffer(unsigned int id);       // Enable vertex buffer (VBO)
//RLAPI void rlDisableVertexBuffer(void);                 // Disable vertex buffer (VBO)
//RLAPI void rlEnableVertexBufferElement(unsigned int id);// Enable vertex buffer element (VBO element)
//RLAPI void rlDisableVertexBufferElement(void);          // Disable vertex buffer element (VBO element)
//RLAPI void rlEnableVertexAttribute(unsigned int index); // Enable vertex attribute index
//RLAPI void rlDisableVertexAttribute(unsigned int index);// Disable vertex attribute index
//#if defined(GRAPHICS_API_OPENGL_11)
//RLAPI void rlEnableStatePointer(int vertexAttribType, void *uffer);    // Enable attribute state pointer
//RLAPI void rlDisableStatePointer(int vertexAttribType);                 // Disable attribute state pointer
//#endif
//
//// Textures state
//RLAPI void rlActiveTextureSlot(int slot);               // Select and active a texture slot
//RLAPI void rlEnableTexture(unsigned int id);            // Enable texture
//RLAPI void rlDisableTexture(void);                      // Disable texture
//RLAPI void rlEnableTextureCubemap(unsigned int id);     // Enable texture cubemap
//RLAPI void rlDisableTextureCubemap(void);               // Disable texture cubemap
//RLAPI void rlTextureParameters(unsigned int id, int param, int value); // Set texture parameters (filter, wrap)
//RLAPI void rlCubemapParameters(unsigned int id, int param, int value); // Set cubemap parameters (filter, wrap)
//
//// Shader state
//RLAPI void rlEnableShader(unsigned int id);             // Enable shader program
//RLAPI void rlDisableShader(void);                       // Disable shader program
//
//// Framebuffer state
//RLAPI void rlEnableFramebuffer(unsigned int id);        // Enable render texture (fbo)
//RLAPI void rlDisableFramebuffer(void);                  // Disable render texture (fbo), return to default framebuffer
//RLAPI void rlActiveDrawBuffers(int count);              // Activate multiple draw color buffers
//RLAPI void rlBlitFramebuffer(int srcX, int srcY, int srcWidth, int srcHeight, int dstX, int dstY, int dstWidth, int dstHeight, int bufferMask); // Blit active framebuffer to main framebuffer
//
//// General render state
//RLAPI void rlEnableColorBlend(void);                     // Enable color blending
//RLAPI void rlDisableColorBlend(void);                   // Disable color blending
//RLAPI void rlEnableDepthTest(void);                     // Enable depth test
//RLAPI void rlDisableDepthTest(void);                    // Disable depth test
//RLAPI void rlEnableDepthMask(void);                     // Enable depth write
//RLAPI void rlDisableDepthMask(void);                    // Disable depth write
//RLAPI void rlEnableBackfaceCulling(void);               // Enable backface culling
//RLAPI void rlDisableBackfaceCulling(void);              // Disable backface culling
//RLAPI void rlSetCullFace(int mode);                     // Set face culling mode
//RLAPI void rlEnableScissorTest(void);                   // Enable scissor test
//RLAPI void rlDisableScissorTest(void);                  // Disable scissor test
//RLAPI void rlScissor(int x, int y, int width, int height); // Scissor test
//RLAPI void rlEnableWireMode(void);                      // Enable wire mode
//RLAPI void rlEnablePointMode(void);                     //  Enable point mode
//RLAPI void rlDisableWireMode(void);                     // Disable wire mode ( and point ) maybe rename
//RLAPI void rlSetLineWidth(float width);                 // Set the line drawing width
//RLAPI float rlGetLineWidth(void);                       // Get the line drawing width
//RLAPI void rlEnableSmoothLines(void);                   // Enable line aliasing
//RLAPI void rlDisableSmoothLines(void);                  // Disable line aliasing
//RLAPI void rlEnableStereoRender(void);                  // Enable stereo rendering
//RLAPI void rlDisableStereoRender(void);                 // Disable stereo rendering
//RLAPI bool rlIsStereoRenderEnabled(void);               // Check if stereo render is enabled
//
//RLAPI void rlClearColor(unsigned char r, unsigned char g, unsigned char b, unsigned char a); // Clear color buffer with color
//RLAPI void rlClearScreenBuffers(void);                  // Clear used screen buffers (color and depth)
//RLAPI void rlCheckErrors(void);                         // Check and log OpenGL error codes
//RLAPI void rlSetBlendMode(int mode);                    // Set blending mode
//RLAPI void rlSetBlendFactors(int glSrcFactor, int glDstFactor, int glEquation); // Set blending mode factor and equation (using OpenGL factors)
//RLAPI void rlSetBlendFactorsSeparate(int glSrcRGB, int glDstRGB, int glSrcAlpha, int glDstAlpha, int glEqRGB, int glEqAlpha); // Set blending mode factors and equations separately (using OpenGL factors)
//
////------------------------------------------------------------------------------------
//// Functions Declaration - rlgl functionality
////------------------------------------------------------------------------------------
//// rlgl initialization functions
//RLAPI void rlglInit(int width, int height);             // Initialize rlgl (buffers, shaders, textures, states)
//RLAPI void rlglClose(void);                             // De-initialize rlgl (buffers, shaders, textures)
//RLAPI void rlLoadExtensions(void *oader);              // Load OpenGL extensions (loader function required)
//RLAPI int rlGetVersion(void);                           // Get current OpenGL version
//RLAPI void rlSetFramebufferWidth(int width);            // Set current framebuffer width
//RLAPI int rlGetFramebufferWidth(void);                  // Get default framebuffer width
//RLAPI void rlSetFramebufferHeight(int height);          // Set current framebuffer height
//RLAPI int rlGetFramebufferHeight(void);                 // Get default framebuffer height
//
//RLAPI unsigned int rlGetTextureIdDefault(void);         // Get default texture id
//RLAPI unsigned int rlGetShaderIdDefault(void);          // Get default shader id
//RLAPI int *lGetShaderLocsDefault(void);                // Get default shader locations
//
//// Render batch management
//// NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
//// but this render batch API is exposed in case of custom batches are required
//RLAPI rlRenderBatch rlLoadRenderBatch(int numBuffers, int bufferElements);  // Load a render batch system
//RLAPI void rlUnloadRenderBatch(rlRenderBatch batch);                        // Unload render batch system
//RLAPI void rlDrawRenderBatch(rlRenderBatch *atch);                         // Draw render batch data (Update->Draw->Reset)
//RLAPI void rlSetRenderBatchActive(rlRenderBatch *atch);                    // Set the active render batch for rlgl (NULL for default internal)
//RLAPI void rlDrawRenderBatchActive(void);                                   // Update and draw internal render batch
//RLAPI bool rlCheckRenderBatchLimit(int vCount);                             // Check internal buffer overflow for a given number of vertex
//
//RLAPI void rlSetTexture(unsigned int id);               // Set current texture for render batch and check buffers limits
//
////------------------------------------------------------------------------------------------------------------------------
//
//// Vertex buffers management
//RLAPI unsigned int rlLoadVertexArray(void);                               // Load vertex array (vao) if supported
//RLAPI unsigned int rlLoadVertexBuffer(const void *uffer, int size, bool dynamic);            // Load a vertex buffer attribute
//RLAPI unsigned int rlLoadVertexBufferElement(const void *uffer, int size, bool dynamic);     // Load a new attributes element buffer
//RLAPI void rlUpdateVertexBuffer(unsigned int bufferId, const void *ata, int dataSize, int offset);     // Update GPU buffer with new data
//RLAPI void rlUpdateVertexBufferElements(unsigned int id, const void *ata, int dataSize, int offset);   // Update vertex buffer elements with new data
//RLAPI void rlUnloadVertexArray(unsigned int vaoId);
//RLAPI void rlUnloadVertexBuffer(unsigned int vboId);
//RLAPI void rlSetVertexAttribute(unsigned int index, int compSize, int type, bool normalized, int stride, const void *ointer);
//RLAPI void rlSetVertexAttributeDivisor(unsigned int index, int divisor);
//RLAPI void rlSetVertexAttributeDefault(int locIndex, const void *alue, int attribType, int count); // Set vertex attribute default value
//RLAPI void rlDrawVertexArray(int offset, int count);
//RLAPI void rlDrawVertexArrayElements(int offset, int count, const void *uffer);
//RLAPI void rlDrawVertexArrayInstanced(int offset, int count, int instances);
//RLAPI void rlDrawVertexArrayElementsInstanced(int offset, int count, const void *uffer, int instances);
//
//// Textures management
//RLAPI unsigned int rlLoadTexture(const void *ata, int width, int height, int format, int mipmapCount); // Load texture in GPU
//RLAPI unsigned int rlLoadTextureDepth(int width, int height, bool useRenderBuffer);               // Load depth texture/renderbuffer (to be attached to fbo)
//RLAPI unsigned int rlLoadTextureCubemap(const void *ata, int size, int format);                        // Load texture cubemap
//RLAPI void rlUpdateTexture(unsigned int id, int offsetX, int offsetY, int width, int height, int format, const void *ata);  // Update GPU texture with new data
//RLAPI void rlGetGlTextureFormats(int format, unsigned int *lInternalFormat, unsigned int *lFormat, unsigned int *lType);  // Get OpenGL internal formats
//RLAPI const char *lGetPixelFormatName(unsigned int format);              // Get name string for pixel format
//RLAPI void rlUnloadTexture(unsigned int id);                              // Unload texture from GPU memory
//RLAPI void rlGenTextureMipmaps(unsigned int id, int width, int height, int format, int *ipmaps); // Generate mipmap data for selected texture
//RLAPI void *lReadTexturePixels(unsigned int id, int width, int height, int format);              // Read texture pixel data
//RLAPI unsigned char *lReadScreenPixels(int width, int height);           // Read screen pixel data (color buffer)
//
//// Framebuffer management (fbo)
//RLAPI unsigned int rlLoadFramebuffer(int width, int height);              // Load an empty framebuffer
//RLAPI void rlFramebufferAttach(unsigned int fboId, unsigned int texId, int attachType, int texType, int mipLevel);  // Attach texture/renderbuffer to a framebuffer
//RLAPI bool rlFramebufferComplete(unsigned int id);                        // Verify framebuffer is complete
//RLAPI void rlUnloadFramebuffer(unsigned int id);                          // Delete framebuffer from GPU
//
//// Shaders management
//RLAPI unsigned int rlLoadShaderCode(const char *sCode, const char *sCode);    // Load shader from code strings
//RLAPI unsigned int rlCompileShader(const char *haderCode, int type);           // Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
//RLAPI unsigned int rlLoadShaderProgram(unsigned int vShaderId, unsigned int fShaderId); // Load custom shader program
//RLAPI void rlUnloadShaderProgram(unsigned int id);                              // Unload shader program
//RLAPI int rlGetLocationUniform(unsigned int shaderId, const char *niformName); // Get shader location uniform
//RLAPI int rlGetLocationAttrib(unsigned int shaderId, const char *ttribName);   // Get shader location attribute
//RLAPI void rlSetUniform(int locIndex, const void *alue, int uniformType, int count);   // Set shader value uniform
//RLAPI void rlSetUniformMatrix(int locIndex, Matrix mat);                        // Set shader value matrix
//RLAPI void rlSetUniformSampler(int locIndex, unsigned int textureId);           // Set shader value sampler
//RLAPI void rlSetShader(unsigned int id, int *ocs);                             // Set shader currently active (id and locations)
//
//// Compute shader management
//RLAPI unsigned int rlLoadComputeShaderProgram(unsigned int shaderId);           // Load compute shader program
//RLAPI void rlComputeShaderDispatch(unsigned int groupX, unsigned int groupY, unsigned int groupZ);  // Dispatch compute shader (equivalent to *raw*for graphics pipeline)
//
//// Shader buffer storage object management (ssbo)
//RLAPI unsigned int rlLoadShaderBuffer(unsigned int size, const void *ata, int usageHint); // Load shader storage buffer object (SSBO)
//RLAPI void rlUnloadShaderBuffer(unsigned int ssboId);                           // Unload shader storage buffer object (SSBO)
//RLAPI void rlUpdateShaderBuffer(unsigned int id, const void *ata, unsigned int dataSize, unsigned int offset); // Update SSBO buffer data
//RLAPI void rlBindShaderBuffer(unsigned int id, unsigned int index);             // Bind SSBO buffer
//RLAPI void rlReadShaderBuffer(unsigned int id, void *est, unsigned int count, unsigned int offset); // Read SSBO buffer data (GPU->CPU)
//RLAPI void rlCopyShaderBuffer(unsigned int destId, unsigned int srcId, unsigned int destOffset, unsigned int srcOffset, unsigned int count); // Copy SSBO data between buffers
//RLAPI unsigned int rlGetShaderBufferSize(unsigned int id);                      // Get SSBO buffer size
//
//// Buffer management
//RLAPI void rlBindImageTexture(unsigned int id, unsigned int index, int format, bool readonly);  // Bind image texture
//
//// Matrix state management
//RLAPI Matrix rlGetMatrixModelview(void);                                  // Get internal modelview matrix
//RLAPI Matrix rlGetMatrixProjection(void);                                 // Get internal projection matrix
//RLAPI Matrix rlGetMatrixTransform(void);                                  // Get internal accumulated transform matrix
//RLAPI Matrix rlGetMatrixProjectionStereo(int eye);                        // Get internal projection matrix for stereo render (selected eye)
//RLAPI Matrix rlGetMatrixViewOffsetStereo(int eye);                        // Get internal view offset matrix for stereo render (selected eye)
//RLAPI void rlSetMatrixProjection(Matrix proj);                            // Set a custom projection matrix (replaces internal projection matrix)
//RLAPI void rlSetMatrixModelview(Matrix view);                             // Set a custom modelview matrix (replaces internal modelview matrix)
//RLAPI void rlSetMatrixProjectionStereo(Matrix right, Matrix left);        // Set eyes projection matrices for stereo rendering
//RLAPI void rlSetMatrixViewOffsetStereo(Matrix right, Matrix left);        // Set eyes view offsets matrices for stereo rendering
//
//// Quick and dirty cube/quad buffers load->draw->unload
//RLAPI void rlLoadDrawCube(void);     // Load and draw a cube
//RLAPI void rlLoadDrawQuad(void);     // Load and draw a quad
//
//#if defined(__cplusplus)
//}
//#endif
//
//#endif // RLGL_H
//
///********************************************  RLGL IMPLEMENTATION
//*******************************************/
//
//#if defined(RLGL_IMPLEMENTATION)
//
//#if defined(GRAPHICS_API_OPENGL_11)
//    #if defined(__APPLE__)
//        #include <OpenGL/gl.h>          // OpenGL 1.1 library for OSX
//        #include <OpenGL/glext.h>       // OpenGL extensions library
//    #else
//        // APIENTRY for OpenGL function pointer declarations is required
//        #if !defined(APIENTRY)
//            #if defined(_WIN32)
//                #define APIENTRY __stdcall
//            #else
//                #define APIENTRY
//            #endif
//        #endif
//        // WINGDIAPI definition. Some Windows OpenGL headers need it
//        #if !defined(WINGDIAPI) && defined(_WIN32)
//            #define WINGDIAPI __declspec(dllimport)
//        #endif
//
//        #include <GL/gl.h>              // OpenGL 1.1 library
//    #endif
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_33)
//    #define GLAD_MALLOC RL_MALLOC
//    #define GLAD_FREE RL_FREE
//
//    #define GLAD_GL_IMPLEMENTATION
//    #include "external/glad.h"          // GLAD extensions loading library, includes OpenGL headers
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_ES3)
//    #include <GLES3/gl3.h>              // OpenGL ES 3.0 library
//    #define GL_GLEXT_PROTOTYPES
//    #include <GLES2/gl2ext.h>           // OpenGL ES 2.0 extensions library
//#elif defined(GRAPHICS_API_OPENGL_ES2)
//    // NOTE: OpenGL ES 2.0 can be enabled on PLATFORM_DESKTOP,
//    // in that case, functions are loaded from a custom glad for OpenGL ES 2.0
//    #if defined(PLATFORM_DESKTOP) || defined(PLATFORM_DESKTOP_SDL)
//        #define GLAD_GLES2_IMPLEMENTATION
//        #include "external/glad_gles2.h"
//    #else
//        #define GL_GLEXT_PROTOTYPES
//        //#include <EGL/egl.h>          // EGL library -> not required, platform layer
//        #include <GLES2/gl2.h>          // OpenGL ES 2.0 library
//        #include <GLES2/gl2ext.h>       // OpenGL ES 2.0 extensions library
//    #endif
//
//    // It seems OpenGL ES 2.0 instancing entry points are not defined on Raspberry Pi
//    // provided headers (despite being defined in official Khronos GLES2 headers)
//    #if defined(PLATFORM_DRM)
//    typedef void (GL_APIENTRYP PFNGLDRAWARRAYSINSTANCEDEXTPROC) (GLpub enum mode, GLint start, GLsizei count, GLsizei primcount);
//    typedef void (GL_APIENTRYP PFNGLDRAWELEMENTSINSTANCEDEXTPROC) (GLpub enum mode, GLsizei count, GLpub enum type, const void *ndices, GLsizei primcount);
//    typedef void (GL_APIENTRYP PFNGLVERTEXATTRIBDIVISOREXTPROC) (GLuint index, GLuint divisor);
//    #endif
//#endif
//
//#include <stdlib.h>                     // Required for: malloc(), free()
//#include <string.h>                     // Required for: strcmp(), strlen() [Used in rlglInit(), on extensions loading]
//#include <math.h>                       // Required for: sqrtf(), sinf(), cosf(), floor(), log()
//
////----------------------------------------------------------------------------------
//// Defines and Macros
////----------------------------------------------------------------------------------
//#ifndef PI
//    #define PI 3.14159265358979323846f
//#endif
//#ifndef DEG2RAD
//    #define DEG2RAD (PI/180.0f)
//#endif
//#ifndef RAD2DEG
//    #define RAD2DEG (180.0f/PI)
//#endif
//
//#ifndef GL_SHADING_LANGUAGE_VERSION
//    #define GL_SHADING_LANGUAGE_VERSION         0x8B8C
//#endif
//
//#ifndef GL_COMPRESSED_RGB_S3TC_DXT1_EXT
//    #define GL_COMPRESSED_RGB_S3TC_DXT1_EXT     0x83F0
//#endif
//#ifndef GL_COMPRESSED_RGBA_S3TC_DXT1_EXT
//    #define GL_COMPRESSED_RGBA_S3TC_DXT1_EXT    0x83F1
//#endif
//#ifndef GL_COMPRESSED_RGBA_S3TC_DXT3_EXT
//    #define GL_COMPRESSED_RGBA_S3TC_DXT3_EXT    0x83F2
//#endif
//#ifndef GL_COMPRESSED_RGBA_S3TC_DXT5_EXT
//    #define GL_COMPRESSED_RGBA_S3TC_DXT5_EXT    0x83F3
//#endif
//#ifndef GL_ETC1_RGB8_OES
//    #define GL_ETC1_RGB8_OES                    0x8D64
//#endif
//#ifndef GL_COMPRESSED_RGB8_ETC2
//    #define GL_COMPRESSED_RGB8_ETC2             0x9274
//#endif
//#ifndef GL_COMPRESSED_RGBA8_ETC2_EAC
//    #define GL_COMPRESSED_RGBA8_ETC2_EAC        0x9278
//#endif
//#ifndef GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG
//    #define GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG  0x8C00
//#endif
//#ifndef GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG
//    #define GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG 0x8C02
//#endif
//#ifndef GL_COMPRESSED_RGBA_ASTC_4x4_KHR
//    #define GL_COMPRESSED_RGBA_ASTC_4x4_KHR     0x93b0
//#endif
//#ifndef GL_COMPRESSED_RGBA_ASTC_8x8_KHR
//    #define GL_COMPRESSED_RGBA_ASTC_8x8_KHR     0x93b7
//#endif
//
//#ifndef GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT
//    #define GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT   0x84FF
//#endif
//#ifndef GL_TEXTURE_MAX_ANISOTROPY_EXT
//    #define GL_TEXTURE_MAX_ANISOTROPY_EXT       0x84FE
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_11)
//    #define GL_UNSIGNED_SHORT_5_6_5             0x8363
//    #define GL_UNSIGNED_SHORT_5_5_5_1           0x8034
//    #define GL_UNSIGNED_SHORT_4_4_4_4           0x8033
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_21)
//    #define GL_LUMINANCE                        0x1909
//    #define GL_LUMINANCE_ALPHA                  0x190A
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_ES2)
//    #define glClearDepth                 glClearDepthf
//    #if !defined(GRAPHICS_API_OPENGL_ES3)
//        #define GL_READ_FRAMEBUFFER         GL_FRAMEBUFFER
//        #define GL_DRAW_FRAMEBUFFER         GL_FRAMEBUFFER
//    #endif
//#endif
//
//// Default shader vertex attribute names to set location points
//#ifndef RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION
//    #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Bound by default to shader location: 0
//#endif
//#ifndef RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD
//    #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Bound by default to shader location: 1
//#endif
//#ifndef RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL
//    #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Bound by default to shader location: 2
//#endif
//#ifndef RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR
//    #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Bound by default to shader location: 3
//#endif
//#ifndef RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT
//    #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Bound by default to shader location: 4
//#endif
//#ifndef RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2
//    #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Bound by default to shader location: 5
//#endif
//
//#ifndef RL_DEFAULT_SHADER_UNIFORM_NAME_MVP
//    #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
//#endif
//#ifndef RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW
//    #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
//#endif
//#ifndef RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION
//    #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
//#endif
//#ifndef RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL
//    #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
//#endif
//#ifndef RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL
//    #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
//#endif
//#ifndef RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR
//    #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
//#endif
//#ifndef RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0
//    #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
//#endif
//#ifndef RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1
//    #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
//#endif
//#ifndef RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2
//    #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
//#endif
//
////----------------------------------------------------------------------------------
//// Types and Structures Definition
////----------------------------------------------------------------------------------
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//typedef struct rlglData {
//    rlRenderBatch *urrentBatch;            // Current render batch
//    rlRenderBatch defaultBatch;             // Default internal render batch
//
//    struct {
//        int vertexCounter;                  // Current active render batch vertex counter (generic, used for all batches)
//        float texcoordx, texcoordy;         // Current active texture coordinate (added on glVertex*))
//        float normalx, normaly, normalz;    // Current active normal (added on glVertex*))
//        unsigned char colorr, colorg, colorb, colora;   // Current active color (added on glVertex*))
//
//        int currentMatrixMode;              // Current matrix mode
//        Matrix *urrentMatrix;              // Current matrix pointer
//        Matrix modelview;                   // Default modelview matrix
//        Matrix projection;                  // Default projection matrix
//        Matrix transform;                   // Transform matrix to be used with rlTranslate, rlRotate, rlScale
//        bool transformRequired;             // Require transform matrix application to current draw-call vertex (if required)
//        Matrix stack[RL_MAX_MATRIX_STACK_SIZE];// Matrix stack for push/pop
//        int stackCounter;                   // Matrix stack counter
//
//        unsigned int defaultTextureId;      // Default texture used on shapes/poly drawing (required by shader)
//        unsigned int activeTextureId[RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS];    // Active texture ids to be enabled on batch drawing (0 active by default)
//        unsigned int defaultVShaderId;      // Default vertex shader id (used by default shader program)
//        unsigned int defaultFShaderId;      // Default fragment shader id (used by default shader program)
//        unsigned int defaultShaderId;       // Default shader program id, supports vertex color and diffuse texture
//        int *efaultShaderLocs;             // Default shader locations pointer to be used on rendering
//        unsigned int currentShaderId;       // Current shader id to be used on rendering (by default, defaultShaderId)
//        int *urrentShaderLocs;             // Current shader locations pointer to be used on rendering (by default, defaultShaderLocs)
//
//        bool stereoRender;                  // Stereo rendering flag
//        Matrix projectionStereo[2];         // VR stereo rendering eyes projection matrices
//        Matrix viewOffsetStereo[2];         // VR stereo rendering eyes view offset matrices
//
//        // Blending variables
//        int currentBlendMode;               // Blending mode active
//        int glBlendSrcFactor;               // Blending source factor
//        int glBlendDstFactor;               // Blending destination factor
//        int glBlendEquation;                // Blending equation
//        int glBlendSrcFactorRGB;            // Blending source RGB factor
//        int glBlendDestFactorRGB;           // Blending destination RGB factor
//        int glBlendSrcFactorAlpha;          // Blending source alpha factor
//        int glBlendDestFactorAlpha;         // Blending destination alpha factor
//        int glBlendEquationRGB;             // Blending equation for RGB
//        int glBlendEquationAlpha;           // Blending equation for alpha
//        bool glCustomBlendModeModified;     // Custom blending factor and equation modification status
//
//        int framebufferWidth;               // Current framebuffer width
//        int framebufferHeight;              // Current framebuffer height
//
//    } State;            // Renderer state
//    struct {
//        bool vao;                           // VAO support (OpenGL ES2 could not support VAO extension) (GL_ARB_vertex_array_object)
//        bool instancing;                    // Instancing supported (GL_ANGLE_instanced_arrays, GL_EXT_draw_instanced + GL_EXT_instanced_arrays)
//        bool texNPOT;                       // NPOT textures full support (GL_ARB_texture_non_power_of_two, GL_OES_texture_npot)
//        bool texDepth;                      // Depth textures supported (GL_ARB_depth_texture, GL_OES_depth_texture)
//        bool texDepthWebGL;                 // Depth textures supported WebGL specific (GL_WEBGL_depth_texture)
//        bool texFloat32;                    // float textures support (32 bit per channel) (GL_OES_texture_float)
//        bool texFloat16;                    // half float textures support (16 bit per channel) (GL_OES_texture_half_float)
//        bool texCompDXT;                    // DDS texture compression support (GL_EXT_texture_compression_s3tc, GL_WEBGL_compressed_texture_s3tc, GL_WEBKIT_WEBGL_compressed_texture_s3tc)
//        bool texCompETC1;                   // ETC1 texture compression support (GL_OES_compressed_ETC1_RGB8_texture, GL_WEBGL_compressed_texture_etc1)
//        bool texCompETC2;                   // ETC2/EAC texture compression support (GL_ARB_ES3_compatibility)
//        bool texCompPVRT;                   // PVR texture compression support (GL_IMG_texture_compression_pvrtc)
//        bool texCompASTC;                   // ASTC texture compression support (GL_KHR_texture_compression_astc_hdr, GL_KHR_texture_compression_astc_ldr)
//        bool texMirrorClamp;                // Clamp mirror wrap mode supported (GL_EXT_texture_mirror_clamp)
//        bool texAnisoFilter;                // Anisotropic texture filtering support (GL_EXT_texture_filter_anisotropic)
//        bool computeShader;                 // Compute shaders support (GL_ARB_compute_shader)
//        bool ssbo;                          // Shader storage buffer object support (GL_ARB_shader_storage_buffer_object)
//
//        float maxAnisotropyLevel;           // Maximum anisotropy level supported (minimum is 2.0f)
//        int maxDepthBits;                   // Maximum bits for depth component
//
//    } ExtSupported;     // Extensions supported flags
//} rlglData;
//
//typedef void **lglLoadProc)(const char *ame);   // OpenGL extension functions loader signature (same as GLADloadproc)
//
//#endif  // GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2
//
////----------------------------------------------------------------------------------
//// Global Variables Definition
////----------------------------------------------------------------------------------
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//static rlglData RLGL = { 0 };
//#endif  // GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2
//
//#if defined(GRAPHICS_API_OPENGL_ES2) && !defined(GRAPHICS_API_OPENGL_ES3)
//// NOTE: VAO functionality is exposed through extensions (OES)
//static PFNGLGENVERTEXARRAYSOESPROC glGenVertexArrays = NULL;
//static PFNGLBINDVERTEXARRAYOESPROC glBindVertexArray = NULL;
//static PFNGLDELETEVERTEXARRAYSOESPROC glDeleteVertexArrays = NULL;
//
//// NOTE: Instancing functionality could also be available through extension
//static PFNGLDRAWARRAYSINSTANCEDEXTPROC glDrawArraysInstanced = NULL;
//static PFNGLDRAWELEMENTSINSTANCEDEXTPROC glDrawElementsInstanced = NULL;
//static PFNGLVERTEXATTRIBDIVISOREXTPROC glVertexAttribDivisor = NULL;
//#endif
//
////----------------------------------------------------------------------------------
//// Module specific Functions Declaration
////----------------------------------------------------------------------------------
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//static void rlLoadShaderDefault(void);      // Load default shader
//static void rlUnloadShaderDefault(void);    // Unload default shader
//#if defined(RLGL_SHOW_GL_DETAILS_INFO)
//static const char *lGetCompressedFormatName(int format); // Get compressed format official GL identifier name
//#endif  // RLGL_SHOW_GL_DETAILS_INFO
//#endif  // GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2
//
//static int rlGetPixelDataSize(int width, int height, int format);   // Get pixel data size in bytes (image or texture)
//
//// Auxiliar matrix math functions
//static Matrix rlMatrixIdentity(void);                       // Get identity matrix
//static Matrix rlMatrixMultiply(Matrix left, Matrix right);  // Multiply two matrices
//
////----------------------------------------------------------------------------------
//// Module Functions Definition - Matrix operations
////----------------------------------------------------------------------------------
//
//#if defined(GRAPHICS_API_OPENGL_11)
//// Fallback to OpenGL 1.1 function calls
////---------------------------------------
//void rlMatrixMode(int mode)
//{
//    switch (mode)
//    {
//        case RL_PROJECTION: glMatrixMode(GL_PROJECTION); break;
//        case RL_MODELVIEW: glMatrixMode(GL_MODELVIEW); break;
//        case RL_TEXTURE: glMatrixMode(GL_TEXTURE); break;
//        default: break;
//    }
//}
//
//void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar)
//{
//    glFrustum(left, right, bottom, top, znear, zfar);
//}
//
//void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar)
//{
//    glOrtho(left, right, bottom, top, znear, zfar);
//}
//
//void rlPushMatrix(void) { glPushMatrix(); }
//void rlPopMatrix(void) { glPopMatrix(); }
//void rlLoadIdentity(void) { glLoadIdentity(); }
//void rlTranslatef(float x, float y, float z) { glTranslatef(x, y, z); }
//void rlRotatef(float angle, float x, float y, float z) { glRotatef(angle, x, y, z); }
//void rlScalef(float x, float y, float z) { glScalef(x, y, z); }
//void rlMultMatrixf(const float *atf) { glMultMatrixf(matf); }
//#endif
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//// Choose the current matrix to be transformed
//void rlMatrixMode(int mode)
//{
//    if (mode == RL_PROJECTION) RLGL.State.currentMatrix = &RLGL.State.projection;
//    else if (mode == RL_MODELVIEW) RLGL.State.currentMatrix = &RLGL.State.modelview;
//    //else if (mode == RL_TEXTURE) // Not supported
//
//    RLGL.State.currentMatrixMode = mode;
//}
//
//// Push the current matrix into RLGL.State.stack
//void rlPushMatrix(void)
//{
//    if (RLGL.State.stackCounter >= RL_MAX_MATRIX_STACK_SIZE) TRACELOG(RL_LOG_ERROR, "RLGL: Matrix stack overflow (RL_MAX_MATRIX_STACK_SIZE)");
//
//    if (RLGL.State.currentMatrixMode == RL_MODELVIEW)
//    {
//        RLGL.State.transformRequired = true;
//        RLGL.State.currentMatrix = &RLGL.State.transform;
//    }
//
//    RLGL.State.stack[RLGL.State.stackCounter] = *LGL.State.currentMatrix;
//    RLGL.State.stackCounter++;
//}
//
//// Pop lattest inserted matrix from RLGL.State.stack
//void rlPopMatrix(void)
//{
//    if (RLGL.State.stackCounter > 0)
//    {
//        Matrix mat = RLGL.State.stack[RLGL.State.stackCounter - 1];
//        *LGL.State.currentMatrix = mat;
//        RLGL.State.stackCounter--;
//    }
//
//    if ((RLGL.State.stackCounter == 0) && (RLGL.State.currentMatrixMode == RL_MODELVIEW))
//    {
//        RLGL.State.currentMatrix = &RLGL.State.modelview;
//        RLGL.State.transformRequired = false;
//    }
//}
//
//// Reset current matrix to identity matrix
//void rlLoadIdentity(void)
//{
//    *LGL.State.currentMatrix = rlMatrixIdentity();
//}
//
//// Multiply the current matrix by a translation matrix
//void rlTranslatef(float x, float y, float z)
//{
//    Matrix matTranslation = {
//        1.0f, 0.0f, 0.0f, x,
//        0.0f, 1.0f, 0.0f, y,
//        0.0f, 0.0f, 1.0f, z,
//        0.0f, 0.0f, 0.0f, 1.0f
//    };
//
//    // NOTE: We transpose matrix with multiplication order
//    *LGL.State.currentMatrix = rlMatrixMultiply(matTranslation, *LGL.State.currentMatrix);
//}
//
//// Multiply the current matrix by a rotation matrix
//// NOTE: The provided angle must be in degrees
//void rlRotatef(float angle, float x, float y, float z)
//{
//    Matrix matRotation = rlMatrixIdentity();
//
//    // Axis vector (x, y, z) normalization
//    float lengthSquared = x* + y* + z*;
//    if ((lengthSquared != 1.0f) && (lengthSquared != 0.0f))
//    {
//        float inverseLength = 1.0f/sqrtf(lengthSquared);
//        x * inverseLength;
//        y * inverseLength;
//        z * inverseLength;
//    }
//
//    // Rotation matrix generation
//    float sinres = sinf(DEG2RAD*ngle);
//    float cosres = cosf(DEG2RAD*ngle);
//    float t = 1.0f - cosres;
//
//    matRotation.m0 = x** + cosres;
//    matRotation.m1 = y** + z*inres;
//    matRotation.m2 = z** - y*inres;
//    matRotation.m3 = 0.0f;
//
//    matRotation.m4 = x** - z*inres;
//    matRotation.m5 = y** + cosres;
//    matRotation.m6 = z** + x*inres;
//    matRotation.m7 = 0.0f;
//
//    matRotation.m8 = x** + y*inres;
//    matRotation.m9 = y** - x*inres;
//    matRotation.m10 = z** + cosres;
//    matRotation.m11 = 0.0f;
//
//    matRotation.m12 = 0.0f;
//    matRotation.m13 = 0.0f;
//    matRotation.m14 = 0.0f;
//    matRotation.m15 = 1.0f;
//
//    // NOTE: We transpose matrix with multiplication order
//    *LGL.State.currentMatrix = rlMatrixMultiply(matRotation, *LGL.State.currentMatrix);
//}
//
//// Multiply the current matrix by a scaling matrix
//void rlScalef(float x, float y, float z)
//{
//    Matrix matScale = {
//        x, 0.0f, 0.0f, 0.0f,
//        0.0f, y, 0.0f, 0.0f,
//        0.0f, 0.0f, z, 0.0f,
//        0.0f, 0.0f, 0.0f, 1.0f
//    };
//
//    // NOTE: We transpose matrix with multiplication order
//    *LGL.State.currentMatrix = rlMatrixMultiply(matScale, *LGL.State.currentMatrix);
//}
//
//// Multiply the current matrix by another matrix
//void rlMultMatrixf(const float *atf)
//{
//    // Matrix creation from array
//    Matrix mat = { matf[0], matf[4], matf[8], matf[12],
//                   matf[1], matf[5], matf[9], matf[13],
//                   matf[2], matf[6], matf[10], matf[14],
//                   matf[3], matf[7], matf[11], matf[15] };
//
//    *LGL.State.currentMatrix = rlMatrixMultiply(*LGL.State.currentMatrix, mat);
//}
//
//// Multiply the current matrix by a perspective matrix generated by parameters
//void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar)
//{
//    Matrix matFrustum = { 0 };
//
//    float rl = (float)(right - left);
//    float tb = (float)(top - bottom);
//    float fn = (float)(zfar - znear);
//
//    matFrustum.m0 = ((float) znear*.0f)/rl;
//    matFrustum.m1 = 0.0f;
//    matFrustum.m2 = 0.0f;
//    matFrustum.m3 = 0.0f;
//
//    matFrustum.m4 = 0.0f;
//    matFrustum.m5 = ((float) znear*.0f)/tb;
//    matFrustum.m6 = 0.0f;
//    matFrustum.m7 = 0.0f;
//
//    matFrustum.m8 = ((float)right + (float)left)/rl;
//    matFrustum.m9 = ((float)top + (float)bottom)/tb;
//    matFrustum.m10 = -((float)zfar + (float)znear)/fn;
//    matFrustum.m11 = -1.0f;
//
//    matFrustum.m12 = 0.0f;
//    matFrustum.m13 = 0.0f;
//    matFrustum.m14 = -((float)zfar*float)znear*.0f)/fn;
//    matFrustum.m15 = 0.0f;
//
//    *LGL.State.currentMatrix = rlMatrixMultiply(*LGL.State.currentMatrix, matFrustum);
//}
//
//// Multiply the current matrix by an orthographic matrix generated by parameters
//void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar)
//{
//    // NOTE: If left-right and top-botton values are equal it could create a division by zero,
//    // response to it is platform/compiler dependant
//    Matrix matOrtho = { 0 };
//
//    float rl = (float)(right - left);
//    float tb = (float)(top - bottom);
//    float fn = (float)(zfar - znear);
//
//    matOrtho.m0 = 2.0f/rl;
//    matOrtho.m1 = 0.0f;
//    matOrtho.m2 = 0.0f;
//    matOrtho.m3 = 0.0f;
//    matOrtho.m4 = 0.0f;
//    matOrtho.m5 = 2.0f/tb;
//    matOrtho.m6 = 0.0f;
//    matOrtho.m7 = 0.0f;
//    matOrtho.m8 = 0.0f;
//    matOrtho.m9 = 0.0f;
//    matOrtho.m10 = -2.0f/fn;
//    matOrtho.m11 = 0.0f;
//    matOrtho.m12 = -((float)left + (float)right)/rl;
//    matOrtho.m13 = -((float)top + (float)bottom)/tb;
//    matOrtho.m14 = -((float)zfar + (float)znear)/fn;
//    matOrtho.m15 = 1.0f;
//
//    *LGL.State.currentMatrix = rlMatrixMultiply(*LGL.State.currentMatrix, matOrtho);
//}
//#endif
//
//// Set the viewport area (transformation from normalized device coordinates to window coordinates)
//// NOTE: We store current viewport dimensions
//void rlViewport(int x, int y, int width, int height)
//{
//    glViewport(x, y, width, height);
//}
//
////----------------------------------------------------------------------------------
//// Module Functions Definition - Vertex level operations
////----------------------------------------------------------------------------------
//#if defined(GRAPHICS_API_OPENGL_11)
//// Fallback to OpenGL 1.1 function calls
////---------------------------------------
//void rlBegin(int mode)
//{
//    switch (mode)
//    {
//        case RL_LINES: glBegin(GL_LINES); break;
//        case RL_TRIANGLES: glBegin(GL_TRIANGLES); break;
//        case RL_QUADS: glBegin(GL_QUADS); break;
//        default: break;
//    }
//}
//
//void rlEnd() { glEnd(); }
//void rlVertex2i(int x, int y) { glVertex2i(x, y); }
//void rlVertex2f(float x, float y) { glVertex2f(x, y); }
//void rlVertex3f(float x, float y, float z) { glVertex3f(x, y, z); }
//void rlTexCoord2f(float x, float y) { glTexCoord2f(x, y); }
//void rlNormal3f(float x, float y, float z) { glNormal3f(x, y, z); }
//void rlColor4ub(unsigned char r, unsigned char g, unsigned char b, unsigned char a) { glColor4ub(r, g, b, a); }
//void rlColor3f(float x, float y, float z) { glColor3f(x, y, z); }
//void rlColor4f(float x, float y, float z, float w) { glColor4f(x, y, z, w); }
//#endif
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//// Initialize drawing mode (how to organize vertex)
//void rlBegin(int mode)
//{
//    // Draw mode can be RL_LINES, RL_TRIANGLES and RL_QUADS
//    // NOTE: In all three cases, vertex are accumulated over default internal vertex buffer
//    if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode != mode)
//    {
//        if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount > 0)
//        {
//            // Make sure current RLGL.currentBatch->draws[i].vertexCount is aligned a multiple of 4,
//            // that way, following QUADS drawing will keep aligned with index processing
//            // It implies adding some extra alignment vertex at the end of the draw,
//            // those vertex are not processed but they are considered as an additional offset
//            // for the next set of vertex to be drawn
//            if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_LINES) RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment = ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount < 4)? RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount : RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%4);
//            else if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_TRIANGLES) RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment = ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount < 4)? 1 : (4 - (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%4)));
//            else RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment = 0;
//
//            if (!rlCheckRenderBatchLimit(RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment))
//            {
//                RLGL.State.vertexCounter += RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment;
//                RLGL.currentBatch->drawCounter++;
//            }
//        }
//
//        if (RLGL.currentBatch->drawCounter >= RL_DEFAULT_BATCH_DRAWCALLS) rlDrawRenderBatch(RLGL.currentBatch);
//
//        RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode = mode;
//        RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount = 0;
//        RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].textureId = RLGL.State.defaultTextureId;
//    }
//}
//
//// Finish vertex providing
//void rlEnd(void)
//{
//    // NOTE: Depth increment is dependant on rlOrtho(): z-near and z-far values,
//    // as well as depth buffer bit-depth (16bit or 24bit or 32bit)
//    // Correct increment formula would be: depthInc = (zfar - znear)/pow(2, bits)
//    RLGL.currentBatch->currentDepth += (1.0f/20000.0f);
//}
//
//// Define one vertex (position)
//// NOTE: Vertex position data is the basic information required for drawing
//void rlVertex3f(float x, float y, float z)
//{
//    float tx = x;
//    float ty = y;
//    float tz = z;
//
//    // Transform provided vector if required
//    if (RLGL.State.transformRequired)
//    {
//        tx = RLGL.State.transform.m0* + RLGL.State.transform.m4* + RLGL.State.transform.m8* + RLGL.State.transform.m12;
//        ty = RLGL.State.transform.m1* + RLGL.State.transform.m5* + RLGL.State.transform.m9* + RLGL.State.transform.m13;
//        tz = RLGL.State.transform.m2* + RLGL.State.transform.m6* + RLGL.State.transform.m10* + RLGL.State.transform.m14;
//    }
//
//    // WARNING: We can't break primitives when launching a new batch.
//    // RL_LINES comes in pairs, RL_TRIANGLES come in groups of 3 vertices and RL_QUADS come in groups of 4 vertices.
//    // We must check current draw.mode when a new vertex is required and finish the batch only if the draw.mode draw.vertexCount is %2, %3 or %4
//    if (RLGL.State.vertexCounter > (RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].elementCount* - 4))
//    {
//        if ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_LINES) &&
//            (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%2 == 0))
//        {
//            // Reached the maximum number of vertices for RL_LINES drawing
//            // Launch a draw call but keep current state for next vertices comming
//            // NOTE: We add +1 vertex to the check for security
//            rlCheckRenderBatchLimit(2 + 1);
//        }
//        else if ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_TRIANGLES) &&
//            (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%3 == 0))
//        {
//            rlCheckRenderBatchLimit(3 + 1);
//        }
//        else if ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_QUADS) &&
//            (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%4 == 0))
//        {
//            rlCheckRenderBatchLimit(4 + 1);
//        }
//    }
//
//    // Add vertices
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].vertices[3*LGL.State.vertexCounter] = tx;
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].vertices[3*LGL.State.vertexCounter + 1] = ty;
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].vertices[3*LGL.State.vertexCounter + 2] = tz;
//
//    // Add current texcoord
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].texcoords[2*LGL.State.vertexCounter] = RLGL.State.texcoordx;
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].texcoords[2*LGL.State.vertexCounter + 1] = RLGL.State.texcoordy;
//
//    // WARNING: By default rlVertexBuffer struct does not store normals
//
//    // Add current color
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].colors[4*LGL.State.vertexCounter] = RLGL.State.colorr;
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].colors[4*LGL.State.vertexCounter + 1] = RLGL.State.colorg;
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].colors[4*LGL.State.vertexCounter + 2] = RLGL.State.colorb;
//    RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].colors[4*LGL.State.vertexCounter + 3] = RLGL.State.colora;
//
//    RLGL.State.vertexCounter++;
//    RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount++;
//}
//
//// Define one vertex (position)
//void rlVertex2f(float x, float y)
//{
//    rlVertex3f(x, y, RLGL.currentBatch->currentDepth);
//}
//
//// Define one vertex (position)
//void rlVertex2i(int x, int y)
//{
//    rlVertex3f((float)x, (float)y, RLGL.currentBatch->currentDepth);
//}
//
//// Define one vertex (texture coordinate)
//// NOTE: Texture coordinates are limited to QUADS only
//void rlTexCoord2f(float x, float y)
//{
//    RLGL.State.texcoordx = x;
//    RLGL.State.texcoordy = y;
//}
//
//// Define one vertex (normal)
//// NOTE: Normals limited to TRIANGLES only?
//void rlNormal3f(float x, float y, float z)
//{
//    RLGL.State.normalx = x;
//    RLGL.State.normaly = y;
//    RLGL.State.normalz = z;
//}
//
//// Define one vertex (color)
//void rlColor4ub(unsigned char x, unsigned char y, unsigned char z, unsigned char w)
//{
//    RLGL.State.colorr = x;
//    RLGL.State.colorg = y;
//    RLGL.State.colorb = z;
//    RLGL.State.colora = w;
//}
//
//// Define one vertex (color)
//void rlColor4f(float r, float g, float b, float a)
//{
//    rlColor4ub((unsigned char)(r*55), (unsigned char)(g*55), (unsigned char)(b*55), (unsigned char)(a*55));
//}
//
//// Define one vertex (color)
//void rlColor3f(float x, float y, float z)
//{
//    rlColor4ub((unsigned char)(x*55), (unsigned char)(y*55), (unsigned char)(z*55), 255);
//}
//
//#endif
//
////--------------------------------------------------------------------------------------
//// Module Functions Definition - OpenGL style functions (common to 1.1, 3.3+, ES2)
////--------------------------------------------------------------------------------------
//
//// Set current texture to use
//void rlSetTexture(unsigned int id)
//{
//    if (id == 0)
//    {
//#if defined(GRAPHICS_API_OPENGL_11)
//        rlDisableTexture();
//#else
//        // NOTE: If quads batch limit is reached, we force a draw call and next batch starts
//        if (RLGL.State.vertexCounter >=
//            RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].elementCount*)
//        {
//            rlDrawRenderBatch(RLGL.currentBatch);
//        }
//#endif
//    }
//    else
//    {
//#if defined(GRAPHICS_API_OPENGL_11)
//        rlEnableTexture(id);
//#else
//        if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].textureId != id)
//        {
//            if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount > 0)
//            {
//                // Make sure current RLGL.currentBatch->draws[i].vertexCount is aligned a multiple of 4,
//                // that way, following QUADS drawing will keep aligned with index processing
//                // It implies adding some extra alignment vertex at the end of the draw,
//                // those vertex are not processed but they are considered as an additional offset
//                // for the next set of vertex to be drawn
//                if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_LINES) RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment = ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount < 4)? RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount : RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%4);
//                else if (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode == RL_TRIANGLES) RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment = ((RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount < 4)? 1 : (4 - (RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount%4)));
//                else RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment = 0;
//
//                if (!rlCheckRenderBatchLimit(RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment))
//                {
//                    RLGL.State.vertexCounter += RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexAlignment;
//
//                    RLGL.currentBatch->drawCounter++;
//                }
//            }
//
//            if (RLGL.currentBatch->drawCounter >= RL_DEFAULT_BATCH_DRAWCALLS) rlDrawRenderBatch(RLGL.currentBatch);
//
//            RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].textureId = id;
//            RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].vertexCount = 0;
//        }
//#endif
//    }
//}
//
//// Select and active a texture slot
//void rlActiveTextureSlot(int slot)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glActiveTexture(GL_TEXTURE0 + slot);
//#endif
//}
//
//// Enable texture
//void rlEnableTexture(unsigned int id)
//{
//#if defined(GRAPHICS_API_OPENGL_11)
//    glEnable(GL_TEXTURE_2D);
//#endif
//    glBindTexture(GL_TEXTURE_2D, id);
//}
//
//// Disable texture
//void rlDisableTexture(void)
//{
//#if defined(GRAPHICS_API_OPENGL_11)
//    glDisable(GL_TEXTURE_2D);
//#endif
//    glBindTexture(GL_TEXTURE_2D, 0);
//}
//
//// Enable texture cubemap
//void rlEnableTextureCubemap(unsigned int id)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindTexture(GL_TEXTURE_CUBE_MAP, id);
//#endif
//}
//
//// Disable texture cubemap
//void rlDisableTextureCubemap(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
//#endif
//}
//
//// Set texture parameters (wrap mode/filter mode)
//void rlTextureParameters(unsigned int id, int param, int value)
//{
//    glBindTexture(GL_TEXTURE_2D, id);
//
//#if !defined(GRAPHICS_API_OPENGL_11)
//    // Reset anisotropy filter, in case it was set
//    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f);
//#endif
//
//    switch (param)
//    {
//        case RL_TEXTURE_WRAP_S:
//        case RL_TEXTURE_WRAP_T:
//        {
//            if (value == RL_TEXTURE_WRAP_MIRROR_CLAMP)
//            {
//#if !defined(GRAPHICS_API_OPENGL_11)
//                if (RLGL.ExtSupported.texMirrorClamp) glTexParameteri(GL_TEXTURE_2D, param, value);
//                else TRACELOG(RL_LOG_WARNING, "GL: Clamp mirror wrap mode not supported (GL_MIRROR_CLAMP_EXT)");
//#endif
//            }
//            else glTexParameteri(GL_TEXTURE_2D, param, value);
//
//        } break;
//        case RL_TEXTURE_MAG_FILTER:
//        case RL_TEXTURE_MIN_FILTER: glTexParameteri(GL_TEXTURE_2D, param, value); break;
//        case RL_TEXTURE_FILTER_ANISOTROPIC:
//        {
//#if !defined(GRAPHICS_API_OPENGL_11)
//            if (value <= RLGL.ExtSupported.maxAnisotropyLevel) glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, (float)value);
//            else if (RLGL.ExtSupported.maxAnisotropyLevel > 0.0f)
//            {
//                TRACELOG(RL_LOG_WARNING, "GL: Maximum anisotropic filter level supported is %iX", id, (int)RLGL.ExtSupported.maxAnisotropyLevel);
//                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, (float)value);
//            }
//            else TRACELOG(RL_LOG_WARNING, "GL: Anisotropic filtering not supported");
//#endif
//        } break;
//#if defined(GRAPHICS_API_OPENGL_33)
//        case RL_TEXTURE_MIPMAP_BIAS_RATIO: glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, value/100.0f);
//#endif
//        default: break;
//    }
//
//    glBindTexture(GL_TEXTURE_2D, 0);
//}
//
//// Set cubemap parameters (wrap mode/filter mode)
//void rlCubemapParameters(unsigned int id, int param, int value)
//{
//#if !defined(GRAPHICS_API_OPENGL_11)
//    glBindTexture(GL_TEXTURE_CUBE_MAP, id);
//
//    // Reset anisotropy filter, in case it was set
//    glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1.0f);
//
//    switch (param)
//    {
//        case RL_TEXTURE_WRAP_S:
//        case RL_TEXTURE_WRAP_T:
//        {
//            if (value == RL_TEXTURE_WRAP_MIRROR_CLAMP)
//            {
//                if (RLGL.ExtSupported.texMirrorClamp) glTexParameteri(GL_TEXTURE_CUBE_MAP, param, value);
//                else TRACELOG(RL_LOG_WARNING, "GL: Clamp mirror wrap mode not supported (GL_MIRROR_CLAMP_EXT)");
//            }
//            else glTexParameteri(GL_TEXTURE_CUBE_MAP, param, value);
//
//        } break;
//        case RL_TEXTURE_MAG_FILTER:
//        case RL_TEXTURE_MIN_FILTER: glTexParameteri(GL_TEXTURE_CUBE_MAP, param, value); break;
//        case RL_TEXTURE_FILTER_ANISOTROPIC:
//        {
//            if (value <= RLGL.ExtSupported.maxAnisotropyLevel) glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAX_ANISOTROPY_EXT, (float)value);
//            else if (RLGL.ExtSupported.maxAnisotropyLevel > 0.0f)
//            {
//                TRACELOG(RL_LOG_WARNING, "GL: Maximum anisotropic filter level supported is %iX", id, (int)RLGL.ExtSupported.maxAnisotropyLevel);
//                glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAX_ANISOTROPY_EXT, (float)value);
//            }
//            else TRACELOG(RL_LOG_WARNING, "GL: Anisotropic filtering not supported");
//        } break;
//#if defined(GRAPHICS_API_OPENGL_33)
//        case RL_TEXTURE_MIPMAP_BIAS_RATIO: glTexParameterf(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_LOD_BIAS, value/100.0f);
//#endif
//        default: break;
//    }
//
//    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
//#endif
//}
//
//// Enable shader program
//void rlEnableShader(unsigned int id)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2))
//    glUseProgram(id);
//#endif
//}
//
//// Disable shader program
//void rlDisableShader(void)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2))
//    glUseProgram(0);
//#endif
//}
//
//// Enable rendering to texture (fbo)
//void rlEnableFramebuffer(unsigned int id)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    glBindFramebuffer(GL_FRAMEBUFFER, id);
//#endif
//}
//
//// Disable rendering to texture
//void rlDisableFramebuffer(void)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//#endif
//}
//
//// Blit active framebuffer to main framebuffer
//void rlBlitFramebuffer(int srcX, int srcY, int srcWidth, int srcHeight, int dstX, int dstY, int dstWidth, int dstHeight, int bufferMask)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES3)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    glBlitFramebuffer(srcX, srcY, srcWidth, srcHeight, dstX, dstY, dstWidth, dstHeight, bufferMask, GL_NEAREST);
//#endif
//}
//
//// Activate multiple draw color buffers
//// NOTE: One color buffer is always active by default
//void rlActiveDrawBuffers(int count)
//{
//#if ((defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES3)) && defined(RLGL_RENDER_TEXTURES_HINT))
//    // NOTE: Maximum number of draw buffers supported is implementation dependant,
//    // it can be queried with glGet*) but it must be at least 8
//    //GLint maxDrawBuffers = 0;
//    //glGetIntegerv(GL_MAX_DRAW_BUFFERS, &maxDrawBuffers);
//
//    if (count > 0)
//    {
//        if (count > 8) TRACELOG(LOG_WARNING, "GL: Max color buffers limited to 8");
//        else
//        {
//            unsigned int buffers[8] = {
//#if defined(GRAPHICS_API_OPENGL_ES3)
//                GL_COLOR_ATTACHMENT0_EXT,
//                GL_COLOR_ATTACHMENT1_EXT,
//                GL_COLOR_ATTACHMENT2_EXT,
//                GL_COLOR_ATTACHMENT3_EXT,
//                GL_COLOR_ATTACHMENT4_EXT,
//                GL_COLOR_ATTACHMENT5_EXT,
//                GL_COLOR_ATTACHMENT6_EXT,
//                GL_COLOR_ATTACHMENT7_EXT,
//#else
//                GL_COLOR_ATTACHMENT0,
//                GL_COLOR_ATTACHMENT1,
//                GL_COLOR_ATTACHMENT2,
//                GL_COLOR_ATTACHMENT3,
//                GL_COLOR_ATTACHMENT4,
//                GL_COLOR_ATTACHMENT5,
//                GL_COLOR_ATTACHMENT6,
//                GL_COLOR_ATTACHMENT7,
//#endif
//            };
//
//#if defined(GRAPHICS_API_OPENGL_ES3)
//            glDrawBuffersEXT(count, buffers);
//#else
//            glDrawBuffers(count, buffers);
//#endif
//        }
//    }
//    else TRACELOG(LOG_WARNING, "GL: One color buffer active by default");
//#endif
//}
//
////----------------------------------------------------------------------------------
//// General render state configuration
////----------------------------------------------------------------------------------
//
//// Enable color blending
//void rlEnableColorBlend(void) { glEnable(GL_BLEND); }
//
//// Disable color blending
//void rlDisableColorBlend(void) { glDisable(GL_BLEND); }
//
//// Enable depth test
//void rlEnableDepthTest(void) { glEnable(GL_DEPTH_TEST); }
//
//// Disable depth test
//void rlDisableDepthTest(void) { glDisable(GL_DEPTH_TEST); }
//
//// Enable depth write
//void rlEnableDepthMask(void) { glDepthMask(GL_TRUE); }
//
//// Disable depth write
//void rlDisableDepthMask(void) { glDepthMask(GL_FALSE); }
//
//// Enable backface culling
//void rlEnableBackfaceCulling(void) { glEnable(GL_CULL_FACE); }
//
//// Disable backface culling
//void rlDisableBackfaceCulling(void) { glDisable(GL_CULL_FACE); }
//
//// Set face culling mode
//void rlSetCullFace(int mode)
//{
//    switch (mode)
//    {
//        case RL_CULL_FACE_BACK: glCullFace(GL_BACK); break;
//        case RL_CULL_FACE_FRONT: glCullFace(GL_FRONT); break;
//        default: break;
//    }
//}
//
//// Enable scissor test
//void rlEnableScissorTest(void) { glEnable(GL_SCISSOR_TEST); }
//
//// Disable scissor test
//void rlDisableScissorTest(void) { glDisable(GL_SCISSOR_TEST); }
//
//// Scissor test
//void rlScissor(int x, int y, int width, int height) { glScissor(x, y, width, height); }
//
//// Enable wire mode
//void rlEnableWireMode(void)
//{
//#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
//    // NOTE: glPolygonMode() not available on OpenGL ES
//    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
//#endif
//}
//
//void rlEnablePointMode(void)
//{
//#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
//    // NOTE: glPolygonMode() not available on OpenGL ES
//    glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
//    glEnable(GL_PROGRAM_POINT_SIZE);
//#endif
//}
//// Disable wire mode
//void rlDisableWireMode(void)
//{
//#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
//    // NOTE: glPolygonMode() not available on OpenGL ES
//    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
//#endif
//}
//
//// Set the line drawing width
//void rlSetLineWidth(float width) { glLineWidth(width); }
//
//// Get the line drawing width
//float rlGetLineWidth(void)
//{
//    float width = 0;
//    glGetFloatv(GL_LINE_WIDTH, &width);
//    return width;
//}
//
//// Enable line aliasing
//void rlEnableSmoothLines(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_11)
//    glEnable(GL_LINE_SMOOTH);
//#endif
//}
//
//// Disable line aliasing
//void rlDisableSmoothLines(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_11)
//    glDisable(GL_LINE_SMOOTH);
//#endif
//}
//
//// Enable stereo rendering
//void rlEnableStereoRender(void)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2))
//    RLGL.State.stereoRender = true;
//#endif
//}
//
//// Disable stereo rendering
//void rlDisableStereoRender(void)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2))
//    RLGL.State.stereoRender = false;
//#endif
//}
//
//// Check if stereo render is enabled
//bool rlIsStereoRenderEnabled(void)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2))
//    return RLGL.State.stereoRender;
//#else
//    return false;
//#endif
//}
//
//// Clear color buffer with color
//void rlClearColor(unsigned char r, unsigned char g, unsigned char b, unsigned char a)
//{
//    // Color values clamp to 0.0f(0) and 1.0f(255)
//    float cr = (float)r/255;
//    float cg = (float)g/255;
//    float cb = (float)b/255;
//    float ca = (float)a/255;
//
//    glClearColor(cr, cg, cb, ca);
//}
//
//// Clear used screen buffers (color and depth)
//void rlClearScreenBuffers(void)
//{
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);     // Clear used buffers: Color and Depth (Depth is used for 3D)
//    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);     // Stencil buffer not used...
//}
//
//// Check and log OpenGL error codes
//void rlCheckErrors()
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    int check = 1;
//    while (check)
//    {
//        const GLpub enum err = glGetError();
//        switch (err)
//        {
//            case GL_NO_ERROR: check = 0; break;
//            case 0x0500: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_INVALID_pub enum"); break;
//            case 0x0501: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_INVALID_VALUE"); break;
//            case 0x0502: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_INVALID_OPERATION"); break;
//            case 0x0503: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_STACK_OVERFLOW"); break;
//            case 0x0504: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_STACK_UNDERFLOW"); break;
//            case 0x0505: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_OUT_OF_MEMORY"); break;
//            case 0x0506: TRACELOG(RL_LOG_WARNING, "GL: Error detected: GL_INVALID_FRAMEBUFFER_OPERATION"); break;
//            default: TRACELOG(RL_LOG_WARNING, "GL: Error detected: Unknown error code: %x", err); break;
//        }
//    }
//#endif
//}
//
//// Set blend mode
//void rlSetBlendMode(int mode)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if ((RLGL.State.currentBlendMode != mode) || ((mode == RL_BLEND_CUSTOM || mode == RL_BLEND_CUSTOM_SEPARATE) && RLGL.State.glCustomBlendModeModified))
//    {
//        rlDrawRenderBatch(RLGL.currentBatch);
//
//        switch (mode)
//        {
//            case RL_BLEND_ALPHA: glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); glBlendEquation(GL_FUNC_ADD); break;
//            case RL_BLEND_ADDITIVE: glBlendFunc(GL_SRC_ALPHA, GL_ONE); glBlendEquation(GL_FUNC_ADD); break;
//            case RL_BLEND_MULTIPLIED: glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA); glBlendEquation(GL_FUNC_ADD); break;
//            case RL_BLEND_ADD_COLORS: glBlendFunc(GL_ONE, GL_ONE); glBlendEquation(GL_FUNC_ADD); break;
//            case RL_BLEND_SUBTRACT_COLORS: glBlendFunc(GL_ONE, GL_ONE); glBlendEquation(GL_FUNC_SUBTRACT); break;
//            case RL_BLEND_ALPHA_PREMULTIPLY: glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); glBlendEquation(GL_FUNC_ADD); break;
//            case RL_BLEND_CUSTOM:
//            {
//                // NOTE: Using GL blend src/dst factors and GL equation configured with rlSetBlendFactors()
//                glBlendFunc(RLGL.State.glBlendSrcFactor, RLGL.State.glBlendDstFactor); glBlendEquation(RLGL.State.glBlendEquation);
//
//            } break;
//            case RL_BLEND_CUSTOM_SEPARATE:
//            {
//                // NOTE: Using GL blend src/dst factors and GL equation configured with rlSetBlendFactorsSeparate()
//                glBlendFuncSeparate(RLGL.State.glBlendSrcFactorRGB, RLGL.State.glBlendDestFactorRGB, RLGL.State.glBlendSrcFactorAlpha, RLGL.State.glBlendDestFactorAlpha);
//                glBlendEquationSeparate(RLGL.State.glBlendEquationRGB, RLGL.State.glBlendEquationAlpha);
//
//            } break;
//            default: break;
//        }
//
//        RLGL.State.currentBlendMode = mode;
//        RLGL.State.glCustomBlendModeModified = false;
//    }
//#endif
//}
//
//// Set blending mode factor and equation
//void rlSetBlendFactors(int glSrcFactor, int glDstFactor, int glEquation)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if ((RLGL.State.glBlendSrcFactor != glSrcFactor) ||
//        (RLGL.State.glBlendDstFactor != glDstFactor) ||
//        (RLGL.State.glBlendEquation != glEquation))
//    {
//        RLGL.State.glBlendSrcFactor = glSrcFactor;
//        RLGL.State.glBlendDstFactor = glDstFactor;
//        RLGL.State.glBlendEquation = glEquation;
//
//        RLGL.State.glCustomBlendModeModified = true;
//    }
//#endif
//}
//
//// Set blending mode factor and equation separately for RGB and alpha
//void rlSetBlendFactorsSeparate(int glSrcRGB, int glDstRGB, int glSrcAlpha, int glDstAlpha, int glEqRGB, int glEqAlpha)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if ((RLGL.State.glBlendSrcFactorRGB != glSrcRGB) ||
//        (RLGL.State.glBlendDestFactorRGB != glDstRGB) ||
//        (RLGL.State.glBlendSrcFactorAlpha != glSrcAlpha) ||
//        (RLGL.State.glBlendDestFactorAlpha != glDstAlpha) ||
//        (RLGL.State.glBlendEquationRGB != glEqRGB) ||
//        (RLGL.State.glBlendEquationAlpha != glEqAlpha))
//    {
//        RLGL.State.glBlendSrcFactorRGB = glSrcRGB;
//        RLGL.State.glBlendDestFactorRGB = glDstRGB;
//        RLGL.State.glBlendSrcFactorAlpha = glSrcAlpha;
//        RLGL.State.glBlendDestFactorAlpha = glDstAlpha;
//        RLGL.State.glBlendEquationRGB = glEqRGB;
//        RLGL.State.glBlendEquationAlpha = glEqAlpha;
//
//        RLGL.State.glCustomBlendModeModified = true;
//    }
//#endif
//}
//
////----------------------------------------------------------------------------------
//// Module Functions Definition - OpenGL Debug
////----------------------------------------------------------------------------------
//#if defined(RLGL_ENABLE_OPENGL_DEBUG_CONTEXT) && defined(GRAPHICS_API_OPENGL_43)
//static void GLAPIENTRY rlDebugMessageCallback(GLpub enum source, GLpub enum type, GLuint id, GLpub enum severity, GLsizei length, const GLchar *essage, const void *serParam)
//{
//    // Ignore non-significant error/warning codes (NVidia drivers)
//    // NOTE: Here there are the details with a sample output:
//    // - #131169 - Framebuffer detailed info: The driver allocated storage for renderbuffer 2. (severity: low)
//    // - #131185 - Buffer detailed info: Buffer object 1 (bound to GL_ELEMENT_ARRAY_BUFFER_ARB, usage hint is GL_pub enum_88e4)
//    //             will use VIDEO memory as the source for buffer object operations. (severity: low)
//    // - #131218 - Program/shader state performance warning: Vertex shader in program 7 is being recompiled based on GL state. (severity: medium)
//    // - #131204 - Texture state usage warning: The texture object (0) bound to texture image unit 0 does not have
//    //             a defined base level and cannot be used for texture mapping. (severity: low)
//    if ((id == 131169) || (id == 131185) || (id == 131218) || (id == 131204)) return;
//
//    const char *sgSource = NULL;
//    switch (source)
//    {
//        case GL_DEBUG_SOURCE_API: msgSource = "API"; break;
//        case GL_DEBUG_SOURCE_WINDOW_SYSTEM: msgSource = "WINDOW_SYSTEM"; break;
//        case GL_DEBUG_SOURCE_SHADER_COMPILER: msgSource = "SHADER_COMPILER"; break;
//        case GL_DEBUG_SOURCE_THIRD_PARTY: msgSource = "THIRD_PARTY"; break;
//        case GL_DEBUG_SOURCE_APPLICATION: msgSource = "APPLICATION"; break;
//        case GL_DEBUG_SOURCE_OTHER: msgSource = "OTHER"; break;
//        default: break;
//    }
//
//    const char *sgType = NULL;
//    switch (type)
//    {
//        case GL_DEBUG_TYPE_ERROR: msgType = "ERROR"; break;
//        case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR: msgType = "DEPRECATED_BEHAVIOR"; break;
//        case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR: msgType = "UNDEFINED_BEHAVIOR"; break;
//        case GL_DEBUG_TYPE_PORTABILITY: msgType = "PORTABILITY"; break;
//        case GL_DEBUG_TYPE_PERFORMANCE: msgType = "PERFORMANCE"; break;
//        case GL_DEBUG_TYPE_MARKER: msgType = "MARKER"; break;
//        case GL_DEBUG_TYPE_PUSH_GROUP: msgType = "PUSH_GROUP"; break;
//        case GL_DEBUG_TYPE_POP_GROUP: msgType = "POP_GROUP"; break;
//        case GL_DEBUG_TYPE_OTHER: msgType = "OTHER"; break;
//        default: break;
//    }
//
//    const char *sgSeverity = "DEFAULT";
//    switch (severity)
//    {
//        case GL_DEBUG_SEVERITY_LOW: msgSeverity = "LOW"; break;
//        case GL_DEBUG_SEVERITY_MEDIUM: msgSeverity = "MEDIUM"; break;
//        case GL_DEBUG_SEVERITY_HIGH: msgSeverity = "HIGH"; break;
//        case GL_DEBUG_SEVERITY_NOTIFICATION: msgSeverity = "NOTIFICATION"; break;
//        default: break;
//    }
//
//    TRACELOG(LOG_WARNING, "GL: OpenGL debug message: %s", message);
//    TRACELOG(LOG_WARNING, "    > Type: %s", msgType);
//    TRACELOG(LOG_WARNING, "    > Source = %s", msgSource);
//    TRACELOG(LOG_WARNING, "    > Severity = %s", msgSeverity);
//}
//#endif
//
////----------------------------------------------------------------------------------
//// Module Functions Definition - rlgl functionality
////----------------------------------------------------------------------------------
//
//// Initialize rlgl: OpenGL extensions, default buffers/shaders/textures, OpenGL states
//void rlglInit(int width, int height)
//{
//    // Enable OpenGL debug context if required
//#if defined(RLGL_ENABLE_OPENGL_DEBUG_CONTEXT) && defined(GRAPHICS_API_OPENGL_43)
//    if ((glDebugMessageCallback != NULL) && (glDebugMessageControl != NULL))
//    {
//        glDebugMessageCallback(rlDebugMessageCallback, 0);
//        // glDebugMessageControl(GL_DEBUG_SOURCE_API, GL_DEBUG_TYPE_ERROR, GL_DEBUG_SEVERITY_HIGH, 0, 0, GL_TRUE);
//
//        // Debug context options:
//        //  - GL_DEBUG_OUTPUT - Faster version but not useful for breakpoints
//        //  - GL_DEBUG_OUTPUT_SYNCHRONUS - Callback is in sync with errors, so a breakpoint can be placed on the callback in order to get a stacktrace for the GL error
//        glEnable(GL_DEBUG_OUTPUT);
//        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
//    }
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // Init default white texture
//    unsigned char pixels[4] = { 255, 255, 255, 255 };   // 1 pixel RGBA (4 bytes)
//    RLGL.State.defaultTextureId = rlLoadTexture(pixels, 1, 1, RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
//
//    if (RLGL.State.defaultTextureId != 0) TRACELOG(RL_LOG_INFO, "TEXTURE: [ID %i] Default texture loaded successfully", RLGL.State.defaultTextureId);
//    else TRACELOG(RL_LOG_WARNING, "TEXTURE: Failed to load default texture");
//
//    // Init default Shader (customized for GL 3.3 and ES2)
//    // Loaded: RLGL.State.defaultShaderId + RLGL.State.defaultShaderLocs
//    rlLoadShaderDefault();
//    RLGL.State.currentShaderId = RLGL.State.defaultShaderId;
//    RLGL.State.currentShaderLocs = RLGL.State.defaultShaderLocs;
//
//    // Init default vertex arrays buffers
//    RLGL.defaultBatch = rlLoadRenderBatch(RL_DEFAULT_BATCH_BUFFERS, RL_DEFAULT_BATCH_BUFFER_ELEMENTS);
//    RLGL.currentBatch = &RLGL.defaultBatch;
//
//    // Init stack matrices (emulating OpenGL 1.1)
//    for (int i = 0; i < RL_MAX_MATRIX_STACK_SIZE; i++) RLGL.State.stack[i] = rlMatrixIdentity();
//
//    // Init internal matrices
//    RLGL.State.transform = rlMatrixIdentity();
//    RLGL.State.projection = rlMatrixIdentity();
//    RLGL.State.modelview = rlMatrixIdentity();
//    RLGL.State.currentMatrix = &RLGL.State.modelview;
//#endif  // GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2
//
//    // Initialize OpenGL default states
//    //----------------------------------------------------------
//    // Init state: Depth test
//    glDepthFunc(GL_LEQUAL);                                 // Type of depth testing to apply
//    glDisable(GL_DEPTH_TEST);                               // Disable depth testing for 2D (only used for 3D)
//
//    // Init state: Blending mode
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);      // Color blending function (how colors are mixed)
//    glEnable(GL_BLEND);                                     // Enable color blending (required to work with transparencies)
//
//    // Init state: Culling
//    // NOTE: All shapes/models triangles are drawn CCW
//    glCullFace(GL_BACK);                                    // Cull the back face (default)
//    glFrontFace(GL_CCW);                                    // Front face are defined counter clockwise (default)
//    glEnable(GL_CULL_FACE);                                 // Enable backface culling
//
//    // Init state: Cubemap seamless
//#if defined(GRAPHICS_API_OPENGL_33)
//    glEnable(GL_TEXTURE_CUBE_MAP_SEAMLESS);                 // Seamless cubemaps (not supported on OpenGL ES 2.0)
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_11)
//    // Init state: Color hints (deprecated in OpenGL 3.0+)
//    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);      // Improve quality of color and texture coordinate interpolation
//    glShadeModel(GL_SMOOTH);                                // Smooth shading between vertex (vertex colors interpolation)
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // Store screen size into global variables
//    RLGL.State.framebufferWidth = width;
//    RLGL.State.framebufferHeight = height;
//
//    TRACELOG(RL_LOG_INFO, "RLGL: Default OpenGL state initialized successfully");
//    //----------------------------------------------------------
//#endif
//
//    // Init state: Color/Depth buffers clear
//    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);                   // Set clear color (black)
//    glClearDepth(1.0f);                                     // Set clear depth value (default)
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);     // Clear color and depth buffers (depth buffer required for 3D)
//}
//
//// Vertex Buffer Object deinitialization (memory free)
//void rlglClose(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    rlUnloadRenderBatch(RLGL.defaultBatch);
//
//    rlUnloadShaderDefault();          // Unload default shader
//
//    glDeleteTextures(1, &RLGL.State.defaultTextureId); // Unload default texture
//    TRACELOG(RL_LOG_INFO, "TEXTURE: [ID %i] Default texture unloaded successfully", RLGL.State.defaultTextureId);
//#endif
//}
//
//// Load OpenGL extensions
//// NOTE: External loader function must be provided
//void rlLoadExtensions(void *oader)
//{
//#if defined(GRAPHICS_API_OPENGL_33)     // Also defined for GRAPHICS_API_OPENGL_21
//    // NOTE: glad is generated and contains only required OpenGL 3.3 Core extensions (and lower versions)
//    if (gladLoadGL((GLADloadfunc)loader) == 0) TRACELOG(RL_LOG_WARNING, "GLAD: Cannot load OpenGL extensions");
//    else TRACELOG(RL_LOG_INFO, "GLAD: OpenGL extensions loaded successfully");
//
//    // Get number of supported extensions
//    GLint numExt = 0;
//    glGetIntegerv(GL_NUM_EXTENSIONS, &numExt);
//    TRACELOG(RL_LOG_INFO, "GL: Supported extensions count: %i", numExt);
//
//#if defined(RLGL_SHOW_GL_DETAILS_INFO)
//    // Get supported extensions list
//    // WARNING: glGetStringi() not available on OpenGL 2.1
//    TRACELOG(RL_LOG_INFO, "GL: OpenGL extensions:");
//    for (int i = 0; i < numExt; i++) TRACELOG(RL_LOG_INFO, "    %s", glGetStringi(GL_EXTENSIONS, i));
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_21)
//    // Register supported extensions flags
//    // Optional OpenGL 2.1 extensions
//    RLGL.ExtSupported.vao = GLAD_GL_ARB_vertex_array_object;
//    RLGL.ExtSupported.instancing = (GLAD_GL_EXT_draw_instanced && GLAD_GL_ARB_instanced_arrays);
//    RLGL.ExtSupported.texNPOT = GLAD_GL_ARB_texture_non_power_of_two;
//    RLGL.ExtSupported.texFloat32 = GLAD_GL_ARB_texture_float;
//    RLGL.ExtSupported.texFloat16 = GLAD_GL_ARB_texture_float;
//    RLGL.ExtSupported.texDepth = GLAD_GL_ARB_depth_texture;
//    RLGL.ExtSupported.maxDepthBits = 32;
//    RLGL.ExtSupported.texAnisoFilter = GLAD_GL_EXT_texture_filter_anisotropic;
//    RLGL.ExtSupported.texMirrorClamp = GLAD_GL_EXT_texture_mirror_clamp;
//#else
//    // Register supported extensions flags
//    // OpenGL 3.3 extensions supported by default (core)
//    RLGL.ExtSupported.vao = true;
//    RLGL.ExtSupported.instancing = true;
//    RLGL.ExtSupported.texNPOT = true;
//    RLGL.ExtSupported.texFloat32 = true;
//    RLGL.ExtSupported.texFloat16 = true;
//    RLGL.ExtSupported.texDepth = true;
//    RLGL.ExtSupported.maxDepthBits = 32;
//    RLGL.ExtSupported.texAnisoFilter = true;
//    RLGL.ExtSupported.texMirrorClamp = true;
//#endif
//
//    // Optional OpenGL 3.3 extensions
//    RLGL.ExtSupported.texCompASTC = GLAD_GL_KHR_texture_compression_astc_hdr && GLAD_GL_KHR_texture_compression_astc_ldr;
//    RLGL.ExtSupported.texCompDXT = GLAD_GL_EXT_texture_compression_s3tc;  // Texture compression: DXT
//    RLGL.ExtSupported.texCompETC2 = GLAD_GL_ARB_ES3_compatibility;        // Texture compression: ETC2/EAC
//    #if defined(GRAPHICS_API_OPENGL_43)
//    RLGL.ExtSupported.computeShader = GLAD_GL_ARB_compute_shader;
//    RLGL.ExtSupported.ssbo = GLAD_GL_ARB_shader_storage_buffer_object;
//    #endif
//
//#endif  // GRAPHICS_API_OPENGL_33
//
//#if defined(GRAPHICS_API_OPENGL_ES3)
//    // Register supported extensions flags
//    // OpenGL ES 3.0 extensions supported by default (or it should be)
//    RLGL.ExtSupported.vao = true;
//    RLGL.ExtSupported.instancing = true;
//    RLGL.ExtSupported.texNPOT = true;
//    RLGL.ExtSupported.texFloat32 = true;
//    RLGL.ExtSupported.texFloat16 = true;
//    RLGL.ExtSupported.texDepth = true;
//    RLGL.ExtSupported.texDepthWebGL = true;
//    RLGL.ExtSupported.maxDepthBits = 24;
//    RLGL.ExtSupported.texAnisoFilter = true;
//    RLGL.ExtSupported.texMirrorClamp = true;
//    // TODO: Check for additional OpenGL ES 3.0 supported extensions:
//    //RLGL.ExtSupported.texCompDXT = true;
//    //RLGL.ExtSupported.texCompETC1 = true;
//    //RLGL.ExtSupported.texCompETC2 = true;
//    //RLGL.ExtSupported.texCompPVRT = true;
//    //RLGL.ExtSupported.texCompASTC = true;
//    //RLGL.ExtSupported.maxAnisotropyLevel = true;
//    //RLGL.ExtSupported.computeShader = true;
//    //RLGL.ExtSupported.ssbo = true;
//
//#elif defined(GRAPHICS_API_OPENGL_ES2)
//
//    #if defined(PLATFORM_DESKTOP) || defined(PLATFORM_DESKTOP_SDL)
//    // TODO: Support GLAD loader for OpenGL ES 3.0
//    if (gladLoadGLES2((GLADloadfunc)loader) == 0) TRACELOG(RL_LOG_WARNING, "GLAD: Cannot load OpenGL ES2.0 functions");
//    else TRACELOG(RL_LOG_INFO, "GLAD: OpenGL ES 2.0 loaded successfully");
//    #endif
//
//    // Get supported extensions list
//    GLint numExt = 0;
//    const char *extList = RL_MALLOC(512*izeof(const char *); // Allocate 512 strings pointers (2 KB)
//    const char *xtensions = (const char *glGetString(GL_EXTENSIONS);  // One big const string
//
//    // NOTE: We have to duplicate string because glGetString() returns a const string
//    int size = strlen(extensions) + 1;      // Get extensions string size in bytes
//    char *xtensionsDup = (char *RL_CALLOC(size, sizeof(char));
//    strcpy(extensionsDup, extensions);
//    extList[numExt] = extensionsDup;
//
//    for (int i = 0; i < size; i++)
//    {
//        if (extensionsDup[i] == ' ')
//        {
//            extensionsDup[i] = '\0';
//            numExt++;
//            extList[numExt] = &extensionsDup[i + 1];
//        }
//    }
//
//    TRACELOG(RL_LOG_INFO, "GL: Supported extensions count: %i", numExt);
//
//#if defined(RLGL_SHOW_GL_DETAILS_INFO)
//    TRACELOG(RL_LOG_INFO, "GL: OpenGL extensions:");
//    for (int i = 0; i < numExt; i++) TRACELOG(RL_LOG_INFO, "    %s", extList[i]);
//#endif
//
//    // Check required extensions
//    for (int i = 0; i < numExt; i++)
//    {
//        // Check VAO support
//        // NOTE: Only check on OpenGL ES, OpenGL 3.3 has VAO support as core feature
//        if (strcmp(extList[i], (const char *"GL_OES_vertex_array_object") == 0)
//        {
//            // The extension is supported by our hardware and driver, try to get related functions pointers
//            // NOTE: emscripten does not support VAOs natively, it uses emulation and it reduces overall performance...
//            glGenVertexArrays = (PFNGLGENVERTEXARRAYSOESPROC)((rlglLoadProc)loader)("glGenVertexArraysOES");
//            glBindVertexArray = (PFNGLBINDVERTEXARRAYOESPROC)((rlglLoadProc)loader)("glBindVertexArrayOES");
//            glDeleteVertexArrays = (PFNGLDELETEVERTEXARRAYSOESPROC)((rlglLoadProc)loader)("glDeleteVertexArraysOES");
//            //glIsVertexArray = (PFNGLISVERTEXARRAYOESPROC)loader("glIsVertexArrayOES");     // NOTE: Fails in WebGL, omitted
//
//            if ((glGenVertexArrays != NULL) && (glBindVertexArray != NULL) && (glDeleteVertexArrays != NULL)) RLGL.ExtSupported.vao = true;
//        }
//
//        // Check instanced rendering support
//        if (strcmp(extList[i], (const char *"GL_ANGLE_instanced_arrays") == 0)         // Web ANGLE
//        {
//            glDrawArraysInstanced = (PFNGLDRAWARRAYSINSTANCEDEXTPROC)((rlglLoadProc)loader)("glDrawArraysInstancedANGLE");
//            glDrawElementsInstanced = (PFNGLDRAWELEMENTSINSTANCEDEXTPROC)((rlglLoadProc)loader)("glDrawElementsInstancedANGLE");
//            glVertexAttribDivisor = (PFNGLVERTEXATTRIBDIVISOREXTPROC)((rlglLoadProc)loader)("glVertexAttribDivisorANGLE");
//
//            if ((glDrawArraysInstanced != NULL) && (glDrawElementsInstanced != NULL) && (glVertexAttribDivisor != NULL)) RLGL.ExtSupported.instancing = true;
//        }
//        else
//        {
//            if ((strcmp(extList[i], (const char *"GL_EXT_draw_instanced") == 0) &&     // Standard EXT
//                (strcmp(extList[i], (const char *"GL_EXT_instanced_arrays") == 0))
//            {
//                glDrawArraysInstanced = (PFNGLDRAWARRAYSINSTANCEDEXTPROC)((rlglLoadProc)loader)("glDrawArraysInstancedEXT");
//                glDrawElementsInstanced = (PFNGLDRAWELEMENTSINSTANCEDEXTPROC)((rlglLoadProc)loader)("glDrawElementsInstancedEXT");
//                glVertexAttribDivisor = (PFNGLVERTEXATTRIBDIVISOREXTPROC)((rlglLoadProc)loader)("glVertexAttribDivisorEXT");
//
//                if ((glDrawArraysInstanced != NULL) && (glDrawElementsInstanced != NULL) && (glVertexAttribDivisor != NULL)) RLGL.ExtSupported.instancing = true;
//            }
//        }
//
//        // Check NPOT textures support
//        // NOTE: Only check on OpenGL ES, OpenGL 3.3 has NPOT textures full support as core feature
//        if (strcmp(extList[i], (const char *"GL_OES_texture_npot") == 0) RLGL.ExtSupported.texNPOT = true;
//
//        // Check texture float support
//        if (strcmp(extList[i], (const char *"GL_OES_texture_float") == 0) RLGL.ExtSupported.texFloat32 = true;
//        if (strcmp(extList[i], (const char *"GL_OES_texture_half_float") == 0) RLGL.ExtSupported.texFloat16 = true;
//
//        // Check depth texture support
//        if (strcmp(extList[i], (const char *"GL_OES_depth_texture") == 0) RLGL.ExtSupported.texDepth = true;
//        if (strcmp(extList[i], (const char *"GL_WEBGL_depth_texture") == 0) RLGL.ExtSupported.texDepthWebGL = true;    // WebGL requires unsized internal format
//        if (RLGL.ExtSupported.texDepthWebGL) RLGL.ExtSupported.texDepth = true;
//
//        if (strcmp(extList[i], (const char *"GL_OES_depth24") == 0) RLGL.ExtSupported.maxDepthBits = 24;   // Not available on WebGL
//        if (strcmp(extList[i], (const char *"GL_OES_depth32") == 0) RLGL.ExtSupported.maxDepthBits = 32;   // Not available on WebGL
//
//        // Check texture compression support: DXT
//        if ((strcmp(extList[i], (const char *"GL_EXT_texture_compression_s3tc") == 0) ||
//            (strcmp(extList[i], (const char *"GL_WEBGL_compressed_texture_s3tc") == 0) ||
//            (strcmp(extList[i], (const char *"GL_WEBKIT_WEBGL_compressed_texture_s3tc") == 0)) RLGL.ExtSupported.texCompDXT = true;
//
//        // Check texture compression support: ETC1
//        if ((strcmp(extList[i], (const char *"GL_OES_compressed_ETC1_RGB8_texture") == 0) ||
//            (strcmp(extList[i], (const char *"GL_WEBGL_compressed_texture_etc1") == 0)) RLGL.ExtSupported.texCompETC1 = true;
//
//        // Check texture compression support: ETC2/EAC
//        if (strcmp(extList[i], (const char *"GL_ARB_ES3_compatibility") == 0) RLGL.ExtSupported.texCompETC2 = true;
//
//        // Check texture compression support: PVR
//        if (strcmp(extList[i], (const char *"GL_IMG_texture_compression_pvrtc") == 0) RLGL.ExtSupported.texCompPVRT = true;
//
//        // Check texture compression support: ASTC
//        if (strcmp(extList[i], (const char *"GL_KHR_texture_compression_astc_hdr") == 0) RLGL.ExtSupported.texCompASTC = true;
//
//        // Check anisotropic texture filter support
//        if (strcmp(extList[i], (const char *"GL_EXT_texture_filter_anisotropic") == 0) RLGL.ExtSupported.texAnisoFilter = true;
//
//        // Check clamp mirror wrap mode support
//        if (strcmp(extList[i], (const char *"GL_EXT_texture_mirror_clamp") == 0) RLGL.ExtSupported.texMirrorClamp = true;
//    }
//
//    // Free extensions pointers
//    RL_FREE(extList);
//    RL_FREE(extensionsDup);    // Duplicated string must be deallocated
//#endif  // GRAPHICS_API_OPENGL_ES2
//
//    // Check OpenGL information and capabilities
//    //------------------------------------------------------------------------------
//    // Show current OpenGL and GLSL version
//    TRACELOG(RL_LOG_INFO, "GL: OpenGL device information:");
//    TRACELOG(RL_LOG_INFO, "    > Vendor:   %s", glGetString(GL_VENDOR));
//    TRACELOG(RL_LOG_INFO, "    > Renderer: %s", glGetString(GL_RENDERER));
//    TRACELOG(RL_LOG_INFO, "    > Version:  %s", glGetString(GL_VERSION));
//    TRACELOG(RL_LOG_INFO, "    > GLSL:     %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // NOTE: Anisotropy levels capability is an extension
//    #ifndef GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT
//        #define GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT 0x84FF
//    #endif
//    glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &RLGL.ExtSupported.maxAnisotropyLevel);
//
//#if defined(RLGL_SHOW_GL_DETAILS_INFO)
//    // Show some OpenGL GPU capabilities
//    TRACELOG(RL_LOG_INFO, "GL: OpenGL capabilities:");
//    GLint capability = 0;
//    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_TEXTURE_SIZE: %i", capability);
//    glGetIntegerv(GL_MAX_CUBE_MAP_TEXTURE_SIZE, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_CUBE_MAP_TEXTURE_SIZE: %i", capability);
//    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_TEXTURE_IMAGE_UNITS: %i", capability);
//    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_VERTEX_ATTRIBS: %i", capability);
//    #if !defined(GRAPHICS_API_OPENGL_ES2)
//    glGetIntegerv(GL_MAX_UNIFORM_BLOCK_SIZE, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_UNIFORM_BLOCK_SIZE: %i", capability);
//    glGetIntegerv(GL_MAX_DRAW_BUFFERS, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_DRAW_BUFFERS: %i", capability);
//    if (RLGL.ExtSupported.texAnisoFilter) TRACELOG(RL_LOG_INFO, "    GL_MAX_TEXTURE_MAX_ANISOTROPY: %.0f", RLGL.ExtSupported.maxAnisotropyLevel);
//    #endif
//    glGetIntegerv(GL_NUM_COMPRESSED_TEXTURE_FORMATS, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_NUM_COMPRESSED_TEXTURE_FORMATS: %i", capability);
//    GLint *ompFormats = (GLint *RL_CALLOC(capability, sizeof(GLint));
//    glGetIntegerv(GL_COMPRESSED_TEXTURE_FORMATS, compFormats);
//    for (int i = 0; i < capability; i++) TRACELOG(RL_LOG_INFO, "        %s", rlGetCompressedFormatName(compFormats[i]));
//    RL_FREE(compFormats);
//
//#if defined(GRAPHICS_API_OPENGL_43)
//    glGetIntegerv(GL_MAX_VERTEX_ATTRIB_BINDINGS, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_VERTEX_ATTRIB_BINDINGS: %i", capability);
//    glGetIntegerv(GL_MAX_UNIFORM_LOCATIONS, &capability);
//    TRACELOG(RL_LOG_INFO, "    GL_MAX_UNIFORM_LOCATIONS: %i", capability);
//#endif  // GRAPHICS_API_OPENGL_43
//#else   // RLGL_SHOW_GL_DETAILS_INFO
//
//    // Show some basic info about GL supported features
//    if (RLGL.ExtSupported.vao) TRACELOG(RL_LOG_INFO, "GL: VAO extension detected, VAO functions loaded successfully");
//    else TRACELOG(RL_LOG_WARNING, "GL: VAO extension not found, VAO not supported");
//    if (RLGL.ExtSupported.texNPOT) TRACELOG(RL_LOG_INFO, "GL: NPOT textures extension detected, full NPOT textures supported");
//    else TRACELOG(RL_LOG_WARNING, "GL: NPOT textures extension not found, limited NPOT support (no-mipmaps, no-repeat)");
//    if (RLGL.ExtSupported.texCompDXT) TRACELOG(RL_LOG_INFO, "GL: DXT compressed textures supported");
//    if (RLGL.ExtSupported.texCompETC1) TRACELOG(RL_LOG_INFO, "GL: ETC1 compressed textures supported");
//    if (RLGL.ExtSupported.texCompETC2) TRACELOG(RL_LOG_INFO, "GL: ETC2/EAC compressed textures supported");
//    if (RLGL.ExtSupported.texCompPVRT) TRACELOG(RL_LOG_INFO, "GL: PVRT compressed textures supported");
//    if (RLGL.ExtSupported.texCompASTC) TRACELOG(RL_LOG_INFO, "GL: ASTC compressed textures supported");
//    if (RLGL.ExtSupported.computeShader) TRACELOG(RL_LOG_INFO, "GL: Compute shaders supported");
//    if (RLGL.ExtSupported.ssbo) TRACELOG(RL_LOG_INFO, "GL: Shader storage buffer objects supported");
//#endif  // RLGL_SHOW_GL_DETAILS_INFO
//
//#endif  // GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2
//}
//
//// Get current OpenGL version
//int rlGetVersion(void)
//{
//    int glVersion = 0;
//#if defined(GRAPHICS_API_OPENGL_11)
//    glVersion = RL_OPENGL_11;
//#endif
//#if defined(GRAPHICS_API_OPENGL_21)
//    glVersion = RL_OPENGL_21;
//#elif defined(GRAPHICS_API_OPENGL_43)
//    glVersion = RL_OPENGL_43;
//#elif defined(GRAPHICS_API_OPENGL_33)
//    glVersion = RL_OPENGL_33;
//#endif
//#if defined(GRAPHICS_API_OPENGL_ES3)
//    glVersion = RL_OPENGL_ES_30;
//#elif defined(GRAPHICS_API_OPENGL_ES2)
//    glVersion = RL_OPENGL_ES_20;
//#endif
//
//    return glVersion;
//}
//
//// Set current framebuffer width
//void rlSetFramebufferWidth(int width)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    RLGL.State.framebufferWidth = width;
//#endif
//}
//
//// Set current framebuffer height
//void rlSetFramebufferHeight(int height)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    RLGL.State.framebufferHeight = height;
//#endif
//}
//
//// Get default framebuffer width
//int rlGetFramebufferWidth(void)
//{
//    int width = 0;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    width = RLGL.State.framebufferWidth;
//#endif
//    return width;
//}
//
//// Get default framebuffer height
//int rlGetFramebufferHeight(void)
//{
//    int height = 0;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    height = RLGL.State.framebufferHeight;
//#endif
//    return height;
//}
//
//// Get default internal texture (white texture)
//// NOTE: Default texture is a 1x1 pixel UNCOMPRESSED_R8G8B8A8
//unsigned int rlGetTextureIdDefault(void)
//{
//    unsigned int id = 0;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    id = RLGL.State.defaultTextureId;
//#endif
//    return id;
//}
//
//// Get default shader id
//unsigned int rlGetShaderIdDefault(void)
//{
//    unsigned int id = 0;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    id = RLGL.State.defaultShaderId;
//#endif
//    return id;
//}
//
//// Get default shader locs
//int *lGetShaderLocsDefault(void)
//{
//    int *ocs = NULL;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    locs = RLGL.State.defaultShaderLocs;
//#endif
//    return locs;
//}
//
//// Render batch management
////------------------------------------------------------------------------------------------------
//// Load render batch
//rlRenderBatch rlLoadRenderBatch(int numBuffers, int bufferElements)
//{
//    rlRenderBatch batch = { 0 };
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // Initialize CPU (RAM) vertex buffers (position, texcoord, color data and indexes)
//    //--------------------------------------------------------------------------------------------
//    batch.vertexBuffer = (rlVertexBuffer *RL_MALLOC(numBuffers*izeof(rlVertexBuffer));
//
//    for (int i = 0; i < numBuffers; i++)
//    {
//        batch.vertexBuffer[i].elementCount = bufferElements;
//
//        batch.vertexBuffer[i].vertices = (float *RL_MALLOC(bufferElements***izeof(float));        // 3 float by vertex, 4 vertex by quad
//        batch.vertexBuffer[i].texcoords = (float *RL_MALLOC(bufferElements***izeof(float));       // 2 float by texcoord, 4 texcoord by quad
//        batch.vertexBuffer[i].colors = (unsigned char *RL_MALLOC(bufferElements***izeof(unsigned char));   // 4 float by color, 4 colors by quad
//#if defined(GRAPHICS_API_OPENGL_33)
//        batch.vertexBuffer[i].indices = (unsigned int *RL_MALLOC(bufferElements**izeof(unsigned int));      // 6 int by quad (indices)
//#endif
//#if defined(GRAPHICS_API_OPENGL_ES2)
//        batch.vertexBuffer[i].indices = (unsigned short *RL_MALLOC(bufferElements**izeof(unsigned short));  // 6 int by quad (indices)
//#endif
//
//        for (int j = 0; j < (3**ufferElements); j++) batch.vertexBuffer[i].vertices[j] = 0.0f;
//        for (int j = 0; j < (2**ufferElements); j++) batch.vertexBuffer[i].texcoords[j] = 0.0f;
//        for (int j = 0; j < (4**ufferElements); j++) batch.vertexBuffer[i].colors[j] = 0;
//
//        int k = 0;
//
//        // Indices can be initialized right now
//        for (int j = 0; j < (6*ufferElements); j += 6)
//        {
//            batch.vertexBuffer[i].indices[j] = 4*;
//            batch.vertexBuffer[i].indices[j + 1] = 4* + 1;
//            batch.vertexBuffer[i].indices[j + 2] = 4* + 2;
//            batch.vertexBuffer[i].indices[j + 3] = 4*;
//            batch.vertexBuffer[i].indices[j + 4] = 4* + 2;
//            batch.vertexBuffer[i].indices[j + 5] = 4* + 3;
//
//            k++;
//        }
//
//        RLGL.State.vertexCounter = 0;
//    }
//
//    TRACELOG(RL_LOG_INFO, "RLGL: Render batch vertex buffers loaded successfully in RAM (CPU)");
//    //--------------------------------------------------------------------------------------------
//
//    // Upload to GPU (VRAM) vertex data and initialize VAOs/VBOs
//    //--------------------------------------------------------------------------------------------
//    for (int i = 0; i < numBuffers; i++)
//    {
//        if (RLGL.ExtSupported.vao)
//        {
//            // Initialize Quads VAO
//            glGenVertexArrays(1, &batch.vertexBuffer[i].vaoId);
//            glBindVertexArray(batch.vertexBuffer[i].vaoId);
//        }
//
//        // Quads - Vertex buffers binding and attributes enable
//        // Vertex position buffer (shader-location = 0)
//        glGenBuffers(1, &batch.vertexBuffer[i].vboId[0]);
//        glBindBuffer(GL_ARRAY_BUFFER, batch.vertexBuffer[i].vboId[0]);
//        glBufferData(GL_ARRAY_BUFFER, bufferElements***izeof(float), batch.vertexBuffer[i].vertices, GL_DYNAMIC_DRAW);
//        glEnableVertexAttribArray(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_POSITION]);
//        glVertexAttribPointer(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_POSITION], 3, GL_FLOAT, 0, 0, 0);
//
//        // Vertex texcoord buffer (shader-location = 1)
//        glGenBuffers(1, &batch.vertexBuffer[i].vboId[1]);
//        glBindBuffer(GL_ARRAY_BUFFER, batch.vertexBuffer[i].vboId[1]);
//        glBufferData(GL_ARRAY_BUFFER, bufferElements***izeof(float), batch.vertexBuffer[i].texcoords, GL_DYNAMIC_DRAW);
//        glEnableVertexAttribArray(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_TEXCOORD01]);
//        glVertexAttribPointer(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_TEXCOORD01], 2, GL_FLOAT, 0, 0, 0);
//
//        // Vertex color buffer (shader-location = 3)
//        glGenBuffers(1, &batch.vertexBuffer[i].vboId[2]);
//        glBindBuffer(GL_ARRAY_BUFFER, batch.vertexBuffer[i].vboId[2]);
//        glBufferData(GL_ARRAY_BUFFER, bufferElements***izeof(unsigned char), batch.vertexBuffer[i].colors, GL_DYNAMIC_DRAW);
//        glEnableVertexAttribArray(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_COLOR]);
//        glVertexAttribPointer(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_COLOR], 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, 0);
//
//        // Fill index buffer
//        glGenBuffers(1, &batch.vertexBuffer[i].vboId[3]);
//        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, batch.vertexBuffer[i].vboId[3]);
//#if defined(GRAPHICS_API_OPENGL_33)
//        glBufferData(GL_ELEMENT_ARRAY_BUFFER, bufferElements**izeof(int), batch.vertexBuffer[i].indices, GL_STATIC_DRAW);
//#endif
//#if defined(GRAPHICS_API_OPENGL_ES2)
//        glBufferData(GL_ELEMENT_ARRAY_BUFFER, bufferElements**izeof(short), batch.vertexBuffer[i].indices, GL_STATIC_DRAW);
//#endif
//    }
//
//    TRACELOG(RL_LOG_INFO, "RLGL: Render batch vertex buffers loaded successfully in VRAM (GPU)");
//
//    // Unbind the current VAO
//    if (RLGL.ExtSupported.vao) glBindVertexArray(0);
//    //--------------------------------------------------------------------------------------------
//
//    // Init draw calls tracking system
//    //--------------------------------------------------------------------------------------------
//    batch.draws = (rlDrawCall *RL_MALLOC(RL_DEFAULT_BATCH_DRAWCALLS*izeof(rlDrawCall));
//
//    for (int i = 0; i < RL_DEFAULT_BATCH_DRAWCALLS; i++)
//    {
//        batch.draws[i].mode = RL_QUADS;
//        batch.draws[i].vertexCount = 0;
//        batch.draws[i].vertexAlignment = 0;
//        //batch.draws[i].vaoId = 0;
//        //batch.draws[i].shaderId = 0;
//        batch.draws[i].textureId = RLGL.State.defaultTextureId;
//        //batch.draws[i].RLGL.State.projection = rlMatrixIdentity();
//        //batch.draws[i].RLGL.State.modelview = rlMatrixIdentity();
//    }
//
//    batch.bufferCount = numBuffers;    // Record buffer count
//    batch.drawCounter = 1;             // Reset draws counter
//    batch.currentDepth = -1.0f;         // Reset depth value
//    //--------------------------------------------------------------------------------------------
//#endif
//
//    return batch;
//}
//
//// Unload default internal buffers vertex data from CPU and GPU
//void rlUnloadRenderBatch(rlRenderBatch batch)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // Unbind everything
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
//
//    // Unload all vertex buffers data
//    for (int i = 0; i < batch.bufferCount; i++)
//    {
//        // Unbind VAO attribs data
//        if (RLGL.ExtSupported.vao)
//        {
//            glBindVertexArray(batch.vertexBuffer[i].vaoId);
//            glDisableVertexAttribArray(0);
//            glDisableVertexAttribArray(1);
//            glDisableVertexAttribArray(2);
//            glDisableVertexAttribArray(3);
//            glBindVertexArray(0);
//        }
//
//        // Delete VBOs from GPU (VRAM)
//        glDeleteBuffers(1, &batch.vertexBuffer[i].vboId[0]);
//        glDeleteBuffers(1, &batch.vertexBuffer[i].vboId[1]);
//        glDeleteBuffers(1, &batch.vertexBuffer[i].vboId[2]);
//        glDeleteBuffers(1, &batch.vertexBuffer[i].vboId[3]);
//
//        // Delete VAOs from GPU (VRAM)
//        if (RLGL.ExtSupported.vao) glDeleteVertexArrays(1, &batch.vertexBuffer[i].vaoId);
//
//        // Free vertex arrays memory from CPU (RAM)
//        RL_FREE(batch.vertexBuffer[i].vertices);
//        RL_FREE(batch.vertexBuffer[i].texcoords);
//        RL_FREE(batch.vertexBuffer[i].colors);
//        RL_FREE(batch.vertexBuffer[i].indices);
//    }
//
//    // Unload arrays
//    RL_FREE(batch.vertexBuffer);
//    RL_FREE(batch.draws);
//#endif
//}
//
//// Draw render batch
//// NOTE: We require a pointer to reset batch and increase current buffer (multi-buffer)
//void rlDrawRenderBatch(rlRenderBatch *atch)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // Update batch vertex buffers
//    //------------------------------------------------------------------------------------------------------------
//    // NOTE: If there is not vertex data, buffers doesn't need to be updated (vertexCount > 0)
//    // TODO: If no data changed on the CPU arrays --> No need to re-update GPU arrays (use a change detector flag?)
//    if (RLGL.State.vertexCounter > 0)
//    {
//        // Activate elements VAO
//        if (RLGL.ExtSupported.vao) glBindVertexArray(batch->vertexBuffer[batch->currentBuffer].vaoId);
//
//        // Vertex positions buffer
//        glBindBuffer(GL_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[0]);
//        glBufferSubData(GL_ARRAY_BUFFER, 0, RLGL.State.vertexCounter**izeof(float), batch->vertexBuffer[batch->currentBuffer].vertices);
//        //glBufferData(GL_ARRAY_BUFFER, sizeof(float)***atch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].vertices, GL_DYNAMIC_DRAW);  // Update all buffer
//
//        // Texture coordinates buffer
//        glBindBuffer(GL_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[1]);
//        glBufferSubData(GL_ARRAY_BUFFER, 0, RLGL.State.vertexCounter**izeof(float), batch->vertexBuffer[batch->currentBuffer].texcoords);
//        //glBufferData(GL_ARRAY_BUFFER, sizeof(float)***atch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].texcoords, GL_DYNAMIC_DRAW); // Update all buffer
//
//        // Colors buffer
//        glBindBuffer(GL_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[2]);
//        glBufferSubData(GL_ARRAY_BUFFER, 0, RLGL.State.vertexCounter**izeof(unsigned char), batch->vertexBuffer[batch->currentBuffer].colors);
//        //glBufferData(GL_ARRAY_BUFFER, sizeof(float)***atch->vertexBuffer[batch->currentBuffer].elementCount, batch->vertexBuffer[batch->currentBuffer].colors, GL_DYNAMIC_DRAW);    // Update all buffer
//
//        // NOTE: glMapBuffer() causes sync issue.
//        // If GPU is working with this buffer, glMapBuffer() will wait(stall) until GPU to finish its job.
//        // To avoid waiting (idle), you can call first glBufferData() with NULL pointer before glMapBuffer().
//        // If you do that, the previous data in PBO will be discarded and glMapBuffer() returns a new
//        // allocated pointer immediately even if GPU is still working with the previous data.
//
//        // Another option: map the buffer object into client's memory
//        // Probably this code could be moved somewhere else...
//        // batch->vertexBuffer[batch->currentBuffer].vertices = (float *glMapBuffer(GL_ARRAY_BUFFER, GL_READ_WRITE);
//        // if (batch->vertexBuffer[batch->currentBuffer].vertices)
//        // {
//            // Update vertex data
//        // }
//        // glUnmapBuffer(GL_ARRAY_BUFFER);
//
//        // Unbind the current VAO
//        if (RLGL.ExtSupported.vao) glBindVertexArray(0);
//    }
//    //------------------------------------------------------------------------------------------------------------
//
//    // Draw batch vertex buffers (considering VR stereo if required)
//    //------------------------------------------------------------------------------------------------------------
//    Matrix matProjection = RLGL.State.projection;
//    Matrix matModelView = RLGL.State.modelview;
//
//    int eyeCount = 1;
//    if (RLGL.State.stereoRender) eyeCount = 2;
//
//    for (int eye = 0; eye < eyeCount; eye++)
//    {
//        if (eyeCount == 2)
//        {
//            // Setup current eye viewport (half screen width)
//            rlViewport(eye*LGL.State.framebufferWidth/2, 0, RLGL.State.framebufferWidth/2, RLGL.State.framebufferHeight);
//
//            // Set current eye view offset to modelview matrix
//            rlSetMatrixModelview(rlMatrixMultiply(matModelView, RLGL.State.viewOffsetStereo[eye]));
//            // Set current eye projection matrix
//            rlSetMatrixProjection(RLGL.State.projectionStereo[eye]);
//        }
//
//        // Draw buffers
//        if (RLGL.State.vertexCounter > 0)
//        {
//            // Set current shader and upload current MVP matrix
//            glUseProgram(RLGL.State.currentShaderId);
//
//            // Create modelview-projection matrix and upload to shader
//            Matrix matMVP = rlMatrixMultiply(RLGL.State.modelview, RLGL.State.projection);
//            float matMVPfloat[16] = {
//                matMVP.m0, matMVP.m1, matMVP.m2, matMVP.m3,
//                matMVP.m4, matMVP.m5, matMVP.m6, matMVP.m7,
//                matMVP.m8, matMVP.m9, matMVP.m10, matMVP.m11,
//                matMVP.m12, matMVP.m13, matMVP.m14, matMVP.m15
//            };
//            glUniformMatrix4fv(RLGL.State.currentShaderLocs[RL_SHADER_LOC_MATRIX_MVP], 1, false, matMVPfloat);
//
//            if (RLGL.ExtSupported.vao) glBindVertexArray(batch->vertexBuffer[batch->currentBuffer].vaoId);
//            else
//            {
//                // Bind vertex attrib: position (shader-location = 0)
//                glBindBuffer(GL_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[0]);
//                glVertexAttribPointer(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_POSITION], 3, GL_FLOAT, 0, 0, 0);
//                glEnableVertexAttribArray(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_POSITION]);
//
//                // Bind vertex attrib: texcoord (shader-location = 1)
//                glBindBuffer(GL_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[1]);
//                glVertexAttribPointer(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_TEXCOORD01], 2, GL_FLOAT, 0, 0, 0);
//                glEnableVertexAttribArray(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_TEXCOORD01]);
//
//                // Bind vertex attrib: color (shader-location = 3)
//                glBindBuffer(GL_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[2]);
//                glVertexAttribPointer(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_COLOR], 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, 0);
//                glEnableVertexAttribArray(RLGL.State.currentShaderLocs[RL_SHADER_LOC_VERTEX_COLOR]);
//
//                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, batch->vertexBuffer[batch->currentBuffer].vboId[3]);
//            }
//
//            // Setup some default shader values
//            glUniform4f(RLGL.State.currentShaderLocs[RL_SHADER_LOC_COLOR_DIFFUSE], 1.0f, 1.0f, 1.0f, 1.0f);
//            glUniform1i(RLGL.State.currentShaderLocs[RL_SHADER_LOC_MAP_DIFFUSE], 0);  // Active default sampler2D: texture0
//
//            // Activate additional sampler textures
//            // Those additional textures will be common for all draw calls of the batch
//            for (int i = 0; i < RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS; i++)
//            {
//                if (RLGL.State.activeTextureId[i] > 0)
//                {
//                    glActiveTexture(GL_TEXTURE0 + 1 + i);
//                    glBindTexture(GL_TEXTURE_2D, RLGL.State.activeTextureId[i]);
//                }
//            }
//
//            // Activate default sampler2D texture0 (one texture is always active for default batch shader)
//            // NOTE: Batch system accumulates calls by texture0 changes, additional textures are enabled for all the draw calls
//            glActiveTexture(GL_TEXTURE0);
//
//            for (int i = 0, vertexOffset = 0; i < batch->drawCounter; i++)
//            {
//                // Bind current draw call texture, activated as GL_TEXTURE0 and Bound to sampler2D texture0 by default
//                glBindTexture(GL_TEXTURE_2D, batch->draws[i].textureId);
//
//                if ((batch->draws[i].mode == RL_LINES) || (batch->draws[i].mode == RL_TRIANGLES)) glDrawArrays(batch->draws[i].mode, vertexOffset, batch->draws[i].vertexCount);
//                else
//                {
//#if defined(GRAPHICS_API_OPENGL_33)
//                    // We need to define the number of indices to be processed: elementCount*
//                    // NOTE: The final parameter tells the GPU the offset in bytes from the
//                    // start of the index buffer to the location of the first index to process
//                    glDrawElements(GL_TRIANGLES, batch->draws[i].vertexCount/4*, GL_UNSIGNED_INT, (GLvoid *(vertexOffset/4**izeof(GLuint)));
//#endif
//#if defined(GRAPHICS_API_OPENGL_ES2)
//                    glDrawElements(GL_TRIANGLES, batch->draws[i].vertexCount/4*, GL_UNSIGNED_SHORT, (GLvoid *(vertexOffset/4**izeof(GLushort)));
//#endif
//                }
//
//                vertexOffset += (batch->draws[i].vertexCount + batch->draws[i].vertexAlignment);
//            }
//
//            if (!RLGL.ExtSupported.vao)
//            {
//                glBindBuffer(GL_ARRAY_BUFFER, 0);
//                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
//            }
//
//            glBindTexture(GL_TEXTURE_2D, 0);    // Unbind textures
//        }
//
//        if (RLGL.ExtSupported.vao) glBindVertexArray(0); // Unbind VAO
//
//        glUseProgram(0);    // Unbind shader program
//    }
//
//    // Restore viewport to default measures
//    if (eyeCount == 2) rlViewport(0, 0, RLGL.State.framebufferWidth, RLGL.State.framebufferHeight);
//    //------------------------------------------------------------------------------------------------------------
//
//    // Reset batch buffers
//    //------------------------------------------------------------------------------------------------------------
//    // Reset vertex counter for next frame
//    RLGL.State.vertexCounter = 0;
//
//    // Reset depth for next draw
//    batch->currentDepth = -1.0f;
//
//    // Restore projection/modelview matrices
//    RLGL.State.projection = matProjection;
//    RLGL.State.modelview = matModelView;
//
//    // Reset RLGL.currentBatch->draws array
//    for (int i = 0; i < RL_DEFAULT_BATCH_DRAWCALLS; i++)
//    {
//        batch->draws[i].mode = RL_QUADS;
//        batch->draws[i].vertexCount = 0;
//        batch->draws[i].textureId = RLGL.State.defaultTextureId;
//    }
//
//    // Reset active texture units for next batch
//    for (int i = 0; i < RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS; i++) RLGL.State.activeTextureId[i] = 0;
//
//    // Reset draws counter to one draw for the batch
//    batch->drawCounter = 1;
//    //------------------------------------------------------------------------------------------------------------
//
//    // Change to next buffer in the list (in case of multi-buffering)
//    batch->currentBuffer++;
//    if (batch->currentBuffer >= batch->bufferCount) batch->currentBuffer = 0;
//#endif
//}
//
//// Set the active render batch for rlgl
//void rlSetRenderBatchActive(rlRenderBatch *atch)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    rlDrawRenderBatch(RLGL.currentBatch);
//
//    if (batch != NULL) RLGL.currentBatch = batch;
//    else RLGL.currentBatch = &RLGL.defaultBatch;
//#endif
//}
//
//// Update and draw internal render batch
//void rlDrawRenderBatchActive(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    rlDrawRenderBatch(RLGL.currentBatch);    // NOTE: Stereo rendering is checked inside
//#endif
//}
//
//// Check internal buffer overflow for a given number of vertex
//// and force a rlRenderBatch draw call if required
//bool rlCheckRenderBatchLimit(int vCount)
//{
//    bool overflow = false;
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if ((RLGL.State.vertexCounter + vCount) >=
//        (RLGL.currentBatch->vertexBuffer[RLGL.currentBatch->currentBuffer].elementCount*))
//    {
//        overflow = true;
//
//        // Store current primitive drawing mode and texture id
//        int currentMode = RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode;
//        int currentTexture = RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].textureId;
//
//        rlDrawRenderBatch(RLGL.currentBatch);    // NOTE: Stereo rendering is checked inside
//
//        // Restore state of last batch so we can continue adding vertices
//        RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].mode = currentMode;
//        RLGL.currentBatch->draws[RLGL.currentBatch->drawCounter - 1].textureId = currentTexture;
//    }
//#endif
//
//    return overflow;
//}
//
//// Textures data management
////-----------------------------------------------------------------------------------------
//// Convert image data to OpenGL texture (returns OpenGL valid Id)
//unsigned int rlLoadTexture(const void *ata, int width, int height, int format, int mipmapCount)
//{
//    unsigned int id = 0;
//
//    glBindTexture(GL_TEXTURE_2D, 0);    // Free any old binding
//
//    // Check texture format support by OpenGL 1.1 (compressed textures not supported)
//#if defined(GRAPHICS_API_OPENGL_11)
//    if (format >= RL_PIXELFORMAT_COMPRESSED_DXT1_RGB)
//    {
//        TRACELOG(RL_LOG_WARNING, "GL: OpenGL 1.1 does not support GPU compressed texture formats");
//        return id;
//    }
//#else
//    if ((!RLGL.ExtSupported.texCompDXT) && ((format == RL_PIXELFORMAT_COMPRESSED_DXT1_RGB) || (format == RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA) ||
//        (format == RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA) || (format == RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA)))
//    {
//        TRACELOG(RL_LOG_WARNING, "GL: DXT compressed texture format not supported");
//        return id;
//    }
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if ((!RLGL.ExtSupported.texCompETC1) && (format == RL_PIXELFORMAT_COMPRESSED_ETC1_RGB))
//    {
//        TRACELOG(RL_LOG_WARNING, "GL: ETC1 compressed texture format not supported");
//        return id;
//    }
//
//    if ((!RLGL.ExtSupported.texCompETC2) && ((format == RL_PIXELFORMAT_COMPRESSED_ETC2_RGB) || (format == RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA)))
//    {
//        TRACELOG(RL_LOG_WARNING, "GL: ETC2 compressed texture format not supported");
//        return id;
//    }
//
//    if ((!RLGL.ExtSupported.texCompPVRT) && ((format == RL_PIXELFORMAT_COMPRESSED_PVRT_RGB) || (format == RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA)))
//    {
//        TRACELOG(RL_LOG_WARNING, "GL: PVRT compressed texture format not supported");
//        return id;
//    }
//
//    if ((!RLGL.ExtSupported.texCompASTC) && ((format == RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA) || (format == RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA)))
//    {
//        TRACELOG(RL_LOG_WARNING, "GL: ASTC compressed texture format not supported");
//        return id;
//    }
//#endif
//#endif  // GRAPHICS_API_OPENGL_11
//
//    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
//
//    glGenTextures(1, &id);              // Generate texture id
//
//    glBindTexture(GL_TEXTURE_2D, id);
//
//    int mipWidth = width;
//    int mipHeight = height;
//    int mipOffset = 0;          // Mipmap data offset, only used for tracelog
//
//    // NOTE: Added pointer math separately from function to avoid UBSAN complaining
//    unsigned char *ataPtr = NULL;
//    if (data != NULL) dataPtr = (unsigned char *data;
//
//    // Load the different mipmap levels
//    for (int i = 0; i < mipmapCount; i++)
//    {
//        unsigned int mipSize = rlGetPixelDataSize(mipWidth, mipHeight, format);
//
//        unsigned int glInternalFormat, glFormat, glType;
//        rlGetGlTextureFormats(format, &glInternalFormat, &glFormat, &glType);
//
//        TRACELOGD("TEXTURE: Load mipmap level %i (%i x %i), size: %i, offset: %i", i, mipWidth, mipHeight, mipSize, mipOffset);
//
//        if (glInternalFormat != 0)
//        {
//            if (format < RL_PIXELFORMAT_COMPRESSED_DXT1_RGB) glTexImage2D(GL_TEXTURE_2D, i, glInternalFormat, mipWidth, mipHeight, 0, glFormat, glType, dataPtr);
//#if !defined(GRAPHICS_API_OPENGL_11)
//            else glCompressedTexImage2D(GL_TEXTURE_2D, i, glInternalFormat, mipWidth, mipHeight, 0, mipSize, dataPtr);
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_33)
//            if (format == RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE)
//            {
//                GLint swizzleMask[] = { GL_RED, GL_RED, GL_RED, GL_ONE };
//                glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
//            }
//            else if (format == RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA)
//            {
//#if defined(GRAPHICS_API_OPENGL_21)
//                GLint swizzleMask[] = { GL_RED, GL_RED, GL_RED, GL_ALPHA };
//#elif defined(GRAPHICS_API_OPENGL_33)
//                GLint swizzleMask[] = { GL_RED, GL_RED, GL_RED, GL_GREEN };
//#endif
//                glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
//            }
//#endif
//        }
//
//        mipWidth /= 2;
//        mipHeight /= 2;
//        mipOffset += mipSize;       // Increment offset position to next mipmap
//        if (data != NULL) dataPtr += mipSize;         // Increment data pointer to next mipmap
//
//        // Security check for NPOT textures
//        if (mipWidth < 1) mipWidth = 1;
//        if (mipHeight < 1) mipHeight = 1;
//    }
//
//    // Texture parameters configuration
//    // NOTE: glTexParameteri does NOT affect texture uploading, just the way it's used
//#if defined(GRAPHICS_API_OPENGL_ES2)
//    // NOTE: OpenGL ES 2.0 with no GL_OES_texture_npot support (i.e. WebGL) has limited NPOT support, so CLAMP_TO_EDGE must be used
//    if (RLGL.ExtSupported.texNPOT)
//    {
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);       // Set texture to repeat on x-axis
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);       // Set texture to repeat on y-axis
//    }
//    else
//    {
//        // NOTE: If using negative texture coordinates (LoadOBJ()), it does not work!
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);       // Set texture to clamp on x-axis
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);       // Set texture to clamp on y-axis
//    }
//#else
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);       // Set texture to repeat on x-axis
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);       // Set texture to repeat on y-axis
//#endif
//
//    // Magnification and minification filters
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);  // Alternative: GL_LINEAR
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);  // Alternative: GL_LINEAR
//
//#if defined(GRAPHICS_API_OPENGL_33)
//    if (mipmapCount > 1)
//    {
//        // Activate Trilinear filtering if mipmaps are available
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
//    }
//#endif
//
//    // At this point we have the texture loaded in GPU and texture parameters configured
//
//    // NOTE: If mipmaps were not in data, they are not generated automatically
//
//    // Unbind current texture
//    glBindTexture(GL_TEXTURE_2D, 0);
//
//    if (id > 0) TRACELOG(RL_LOG_INFO, "TEXTURE: [ID %i] Texture loaded successfully (%ix%i | %s | %i mipmaps)", id, width, height, rlGetPixelFormatName(format), mipmapCount);
//    else TRACELOG(RL_LOG_WARNING, "TEXTURE: Failed to load texture");
//
//    return id;
//}
//
//// Load depth texture/renderbuffer (to be attached to fbo)
//// WARNING: OpenGL ES 2.0 requires GL_OES_depth_texture and WebGL requires WEBGL_depth_texture extensions
//unsigned int rlLoadTextureDepth(int width, int height, bool useRenderBuffer)
//{
//    unsigned int id = 0;
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // In case depth textures not supported, we force renderbuffer usage
//    if (!RLGL.ExtSupported.texDepth) useRenderBuffer = true;
//
//    // NOTE: We let the implementation to choose the best bit-depth
//    // Possible formats: GL_DEPTH_COMPONENT16, GL_DEPTH_COMPONENT24, GL_DEPTH_COMPONENT32 and GL_DEPTH_COMPONENT32F
//    unsigned int glInternalFormat = GL_DEPTH_COMPONENT;
//
//#if (defined(GRAPHICS_API_OPENGL_ES2) || defined(GRAPHICS_API_OPENGL_ES3))
//    // WARNING: WebGL platform requires unsized internal format definition (GL_DEPTH_COMPONENT)
//    // while other platforms using OpenGL ES 2.0 require/support sized internal formats depending on the GPU capabilities
//    if (!RLGL.ExtSupported.texDepthWebGL || useRenderBuffer)
//    {
//        if (RLGL.ExtSupported.maxDepthBits == 32) glInternalFormat = GL_DEPTH_COMPONENT32_OES;
//        else if (RLGL.ExtSupported.maxDepthBits == 24) glInternalFormat = GL_DEPTH_COMPONENT24_OES;
//        else glInternalFormat = GL_DEPTH_COMPONENT16;
//    }
//#endif
//
//    if (!useRenderBuffer && RLGL.ExtSupported.texDepth)
//    {
//        glGenTextures(1, &id);
//        glBindTexture(GL_TEXTURE_2D, id);
//        glTexImage2D(GL_TEXTURE_2D, 0, glInternalFormat, width, height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, NULL);
//
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//        glBindTexture(GL_TEXTURE_2D, 0);
//
//        TRACELOG(RL_LOG_INFO, "TEXTURE: Depth texture loaded successfully");
//    }
//    else
//    {
//        // Create the renderbuffer that will serve as the depth attachment for the framebuffer
//        // NOTE: A renderbuffer is simpler than a texture and could offer better performance on embedded devices
//        glGenRenderbuffers(1, &id);
//        glBindRenderbuffer(GL_RENDERBUFFER, id);
//        glRenderbufferStorage(GL_RENDERBUFFER, glInternalFormat, width, height);
//
//        glBindRenderbuffer(GL_RENDERBUFFER, 0);
//
//        TRACELOG(RL_LOG_INFO, "TEXTURE: [ID %i] Depth renderbuffer loaded successfully (%i bits)", id, (RLGL.ExtSupported.maxDepthBits >= 24)? RLGL.ExtSupported.maxDepthBits : 16);
//    }
//#endif
//
//    return id;
//}
//
//// Load texture cubemap
//// NOTE: Cubemap data is expected to be 6 images in a single data array (one after the other),
//// expected the following convention: +X, -X, +Y, -Y, +Z, -Z
//unsigned int rlLoadTextureCubemap(const void *ata, int size, int format)
//{
//    unsigned int id = 0;
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    unsigned int dataSize = rlGetPixelDataSize(size, size, format);
//
//    glGenTextures(1, &id);
//    glBindTexture(GL_TEXTURE_CUBE_MAP, id);
//
//    unsigned int glInternalFormat, glFormat, glType;
//    rlGetGlTextureFormats(format, &glInternalFormat, &glFormat, &glType);
//
//    if (glInternalFormat != 0)
//    {
//        // Load cubemap faces
//        for (unsigned int i = 0; i < 6; i++)
//        {
//            if (data == NULL)
//            {
//                if (format < RL_PIXELFORMAT_COMPRESSED_DXT1_RGB)
//                {
//                    if ((format == RL_PIXELFORMAT_UNCOMPRESSED_R32) || (format == RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32)
//                            || (format == RL_PIXELFORMAT_UNCOMPRESSED_R16) || (format == RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16))
//                        TRACELOG(RL_LOG_WARNING, "TEXTURES: Cubemap requested format not supported");
//                    else glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, size, size, 0, glFormat, glType, NULL);
//                }
//                else TRACELOG(RL_LOG_WARNING, "TEXTURES: Empty cubemap creation does not support compressed format");
//            }
//            else
//            {
//                if (format < RL_PIXELFORMAT_COMPRESSED_DXT1_RGB) glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, size, size, 0, glFormat, glType, (unsigned char *data + i*ataSize);
//                else glCompressedTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, glInternalFormat, size, size, 0, dataSize, (unsigned char *data + i*ataSize);
//            }
//
//#if defined(GRAPHICS_API_OPENGL_33)
//            if (format == RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE)
//            {
//                GLint swizzleMask[] = { GL_RED, GL_RED, GL_RED, GL_ONE };
//                glTexParameteriv(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
//            }
//            else if (format == RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA)
//            {
//#if defined(GRAPHICS_API_OPENGL_21)
//                GLint swizzleMask[] = { GL_RED, GL_RED, GL_RED, GL_ALPHA };
//#elif defined(GRAPHICS_API_OPENGL_33)
//                GLint swizzleMask[] = { GL_RED, GL_RED, GL_RED, GL_GREEN };
//#endif
//                glTexParameteriv(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
//            }
//#endif
//        }
//    }
//
//    // Set cubemap texture sampling parameters
//    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//#if defined(GRAPHICS_API_OPENGL_33)
//    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);  // Flag not supported on OpenGL ES 2.0
//#endif
//
//    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
//#endif
//
//    if (id > 0) TRACELOG(RL_LOG_INFO, "TEXTURE: [ID %i] Cubemap texture loaded successfully (%ix%i)", id, size, size);
//    else TRACELOG(RL_LOG_WARNING, "TEXTURE: Failed to load cubemap texture");
//
//    return id;
//}
//
//// Update already loaded texture in GPU with new data
//// NOTE: We don't know safely if internal texture format is the expected one...
//void rlUpdateTexture(unsigned int id, int offsetX, int offsetY, int width, int height, int format, const void *ata)
//{
//    glBindTexture(GL_TEXTURE_2D, id);
//
//    unsigned int glInternalFormat, glFormat, glType;
//    rlGetGlTextureFormats(format, &glInternalFormat, &glFormat, &glType);
//
//    if ((glInternalFormat != 0) && (format < RL_PIXELFORMAT_COMPRESSED_DXT1_RGB))
//    {
//        glTexSubImage2D(GL_TEXTURE_2D, 0, offsetX, offsetY, width, height, glFormat, glType, data);
//    }
//    else TRACELOG(RL_LOG_WARNING, "TEXTURE: [ID %i] Failed to update for current texture format (%i)", id, format);
//}
//
//// Get OpenGL internal formats and data type from raylib PixelFormat
//void rlGetGlTextureFormats(int format, unsigned int *lInternalFormat, unsigned int *lFormat, unsigned int *lType)
//{
//    *lInternalFormat = 0;
//    *lFormat = 0;
//    *lType = 0;
//
//    switch (format)
//    {
//    #if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_21) || defined(GRAPHICS_API_OPENGL_ES2)
//        // NOTE: on OpenGL ES 2.0 (WebGL), internalFormat must match format and options allowed are: GL_LUMINANCE, GL_RGB, GL_RGBA
//        case RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE: *lInternalFormat = GL_LUMINANCE; *lFormat = GL_LUMINANCE; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA: *lInternalFormat = GL_LUMINANCE_ALPHA; *lFormat = GL_LUMINANCE_ALPHA; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5: *lInternalFormat = GL_RGB; *lFormat = GL_RGB; *lType = GL_UNSIGNED_SHORT_5_6_5; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8: *lInternalFormat = GL_RGB; *lFormat = GL_RGB; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1: *lInternalFormat = GL_RGBA; *lFormat = GL_RGBA; *lType = GL_UNSIGNED_SHORT_5_5_5_1; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4: *lInternalFormat = GL_RGBA; *lFormat = GL_RGBA; *lType = GL_UNSIGNED_SHORT_4_4_4_4; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8: *lInternalFormat = GL_RGBA; *lFormat = GL_RGBA; *lType = GL_UNSIGNED_BYTE; break;
//        #if !defined(GRAPHICS_API_OPENGL_11)
//        #if defined(GRAPHICS_API_OPENGL_ES3)
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_R32F_EXT; *lFormat = GL_RED_EXT; *lType = GL_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_RGB32F_EXT; *lFormat = GL_RGB; *lType = GL_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_RGBA32F_EXT; *lFormat = GL_RGBA; *lType = GL_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_R16F_EXT; *lFormat = GL_RED_EXT; *lType = GL_HALF_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGB16F_EXT; *lFormat = GL_RGB; *lType = GL_HALF_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGBA16F_EXT; *lFormat = GL_RGBA; *lType = GL_HALF_FLOAT; break;
//        #else
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_LUMINANCE; *lFormat = GL_LUMINANCE; *lType = GL_FLOAT; break;            // NOTE: Requires extension OES_texture_float
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_RGB; *lFormat = GL_RGB; *lType = GL_FLOAT; break;                  // NOTE: Requires extension OES_texture_float
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_RGBA; *lFormat = GL_RGBA; *lType = GL_FLOAT; break;             // NOTE: Requires extension OES_texture_float
//        #if defined(GRAPHICS_API_OPENGL_21)
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_LUMINANCE; *lFormat = GL_LUMINANCE; *lType = GL_HALF_FLOAT_ARB; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGB; *lFormat = GL_RGB; *lType = GL_HALF_FLOAT_ARB; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGBA; *lFormat = GL_RGBA; *lType = GL_HALF_FLOAT_ARB; break;
//        #else // defined(GRAPHICS_API_OPENGL_ES2)
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_LUMINANCE; *lFormat = GL_LUMINANCE; *lType = GL_HALF_FLOAT_OES; break;   // NOTE: Requires extension OES_texture_half_float
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGB; *lFormat = GL_RGB; *lType = GL_HALF_FLOAT_OES; break;         // NOTE: Requires extension OES_texture_half_float
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGBA; *lFormat = GL_RGBA; *lType = GL_HALF_FLOAT_OES; break;    // NOTE: Requires extension OES_texture_half_float
//        #endif
//        #endif
//        #endif
//    #elif defined(GRAPHICS_API_OPENGL_33)
//        case RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE: *lInternalFormat = GL_R8; *lFormat = GL_RED; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA: *lInternalFormat = GL_RG8; *lFormat = GL_RG; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5: *lInternalFormat = GL_RGB565; *lFormat = GL_RGB; *lType = GL_UNSIGNED_SHORT_5_6_5; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8: *lInternalFormat = GL_RGB8; *lFormat = GL_RGB; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1: *lInternalFormat = GL_RGB5_A1; *lFormat = GL_RGBA; *lType = GL_UNSIGNED_SHORT_5_5_5_1; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4: *lInternalFormat = GL_RGBA4; *lFormat = GL_RGBA; *lType = GL_UNSIGNED_SHORT_4_4_4_4; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8: *lInternalFormat = GL_RGBA8; *lFormat = GL_RGBA; *lType = GL_UNSIGNED_BYTE; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_R32F; *lFormat = GL_RED; *lType = GL_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_RGB32F; *lFormat = GL_RGB; *lType = GL_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32: if (RLGL.ExtSupported.texFloat32) *lInternalFormat = GL_RGBA32F; *lFormat = GL_RGBA; *lType = GL_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_R16F; *lFormat = GL_RED; *lType = GL_HALF_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGB16F; *lFormat = GL_RGB; *lType = GL_HALF_FLOAT; break;
//        case RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16: if (RLGL.ExtSupported.texFloat16) *lInternalFormat = GL_RGBA16F; *lFormat = GL_RGBA; *lType = GL_HALF_FLOAT; break;
//    #endif
//    #if !defined(GRAPHICS_API_OPENGL_11)
//        case RL_PIXELFORMAT_COMPRESSED_DXT1_RGB: if (RLGL.ExtSupported.texCompDXT) *lInternalFormat = GL_COMPRESSED_RGB_S3TC_DXT1_EXT; break;
//        case RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA: if (RLGL.ExtSupported.texCompDXT) *lInternalFormat = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT; break;
//        case RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA: if (RLGL.ExtSupported.texCompDXT) *lInternalFormat = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT; break;
//        case RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA: if (RLGL.ExtSupported.texCompDXT) *lInternalFormat = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT; break;
//        case RL_PIXELFORMAT_COMPRESSED_ETC1_RGB: if (RLGL.ExtSupported.texCompETC1) *lInternalFormat = GL_ETC1_RGB8_OES; break;                      // NOTE: Requires OpenGL ES 2.0 or OpenGL 4.3
//        case RL_PIXELFORMAT_COMPRESSED_ETC2_RGB: if (RLGL.ExtSupported.texCompETC2) *lInternalFormat = GL_COMPRESSED_RGB8_ETC2; break;               // NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
//        case RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA: if (RLGL.ExtSupported.texCompETC2) *lInternalFormat = GL_COMPRESSED_RGBA8_ETC2_EAC; break;     // NOTE: Requires OpenGL ES 3.0 or OpenGL 4.3
//        case RL_PIXELFORMAT_COMPRESSED_PVRT_RGB: if (RLGL.ExtSupported.texCompPVRT) *lInternalFormat = GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG; break;    // NOTE: Requires PowerVR GPU
//        case RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA: if (RLGL.ExtSupported.texCompPVRT) *lInternalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG; break;  // NOTE: Requires PowerVR GPU
//        case RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA: if (RLGL.ExtSupported.texCompASTC) *lInternalFormat = GL_COMPRESSED_RGBA_ASTC_4x4_KHR; break;  // NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3
//        case RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA: if (RLGL.ExtSupported.texCompASTC) *lInternalFormat = GL_COMPRESSED_RGBA_ASTC_8x8_KHR; break;  // NOTE: Requires OpenGL ES 3.1 or OpenGL 4.3
//    #endif
//        default: TRACELOG(RL_LOG_WARNING, "TEXTURE: Current format not supported (%i)", format); break;
//    }
//}
//
//// Unload texture from GPU memory
//void rlUnloadTexture(unsigned int id)
//{
//    glDeleteTextures(1, &id);
//}
//
//// Generate mipmap data for selected texture
//// NOTE: Only supports GPU mipmap generation
//void rlGenTextureMipmaps(unsigned int id, int width, int height, int format, int *ipmaps)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindTexture(GL_TEXTURE_2D, id);
//
//    // Check if texture is power-of-two (POT)
//    bool texIsPOT = false;
//
//    if (((width > 0) && ((width & (width - 1)) == 0)) &&
//        ((height > 0) && ((height & (height - 1)) == 0))) texIsPOT = true;
//
//    if ((texIsPOT) || (RLGL.ExtSupported.texNPOT))
//    {
//        //glHint(GL_GENERATE_MIPMAP_HINT, GL_DONT_CARE);   // Hint for mipmaps generation algorithm: GL_FASTEST, GL_NICEST, GL_DONT_CARE
//        glGenerateMipmap(GL_TEXTURE_2D);    // Generate mipmaps automatically
//
//        #define MIN(a,b) (((a)<(b))? (a):(b))
//        #define MAX(a,b) (((a)>(b))? (a):(b))
//
//        *ipmaps = 1 + (int)floor(log(MAX(width, height))/log(2));
//        TRACELOG(RL_LOG_INFO, "TEXTURE: [ID %i] Mipmaps generated automatically, total: %i", id, *ipmaps);
//    }
//    else TRACELOG(RL_LOG_WARNING, "TEXTURE: [ID %i] Failed to generate mipmaps", id);
//
//    glBindTexture(GL_TEXTURE_2D, 0);
//#else
//    TRACELOG(RL_LOG_WARNING, "TEXTURE: [ID %i] GPU mipmap generation not supported", id);
//#endif
//}
//
//
//// Read texture pixel data
//void *lReadTexturePixels(unsigned int id, int width, int height, int format)
//{
//    void *ixels = NULL;
//
//#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
//    glBindTexture(GL_TEXTURE_2D, id);
//
//    // NOTE: Using texture id, we can retrieve some texture info (but not on OpenGL ES 2.0)
//    // Possible texture info: GL_TEXTURE_RED_SIZE, GL_TEXTURE_GREEN_SIZE, GL_TEXTURE_BLUE_SIZE, GL_TEXTURE_ALPHA_SIZE
//    //int width, height, format;
//    //glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH, &width);
//    //glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT, &height);
//    //glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_INTERNAL_FORMAT, &format);
//
//    // NOTE: Each row written to or read from by OpenGL pixel operations like glGetTexImage are aligned to a 4 byte boundary by default, which may add some padding.
//    // Use glPixelStorei to modify padding with the GL_[UN]PACK_ALIGNMENT setting.
//    // GL_PACK_ALIGNMENT affects operations that read from OpenGL memory (glReadPixels, glGetTexImage, etc.)
//    // GL_UNPACK_ALIGNMENT affects operations that write to OpenGL memory (glTexImage, etc.)
//    glPixelStorei(GL_PACK_ALIGNMENT, 1);
//
//    unsigned int glInternalFormat, glFormat, glType;
//    rlGetGlTextureFormats(format, &glInternalFormat, &glFormat, &glType);
//    unsigned int size = rlGetPixelDataSize(width, height, format);
//
//    if ((glInternalFormat != 0) && (format < RL_PIXELFORMAT_COMPRESSED_DXT1_RGB))
//    {
//        pixels = RL_MALLOC(size);
//        glGetTexImage(GL_TEXTURE_2D, 0, glFormat, glType, pixels);
//    }
//    else TRACELOG(RL_LOG_WARNING, "TEXTURE: [ID %i] Data retrieval not suported for pixel format (%i)", id, format);
//
//    glBindTexture(GL_TEXTURE_2D, 0);
//#endif
//
//#if defined(GRAPHICS_API_OPENGL_ES2)
//    // glGetTexImage() is not available on OpenGL ES 2.0
//    // Texture width and height are required on OpenGL ES 2.0. There is no way to get it from texture id.
//    // Two possible Options:
//    // 1 - Bind texture to color fbo attachment and glReadPixels()
//    // 2 - Create an fbo, activate it, render quad with texture, glReadPixels()
//    // We are using Option 1, just need to care for texture format on retrieval
//    // NOTE: This behaviour could be conditioned by graphic driver...
//    unsigned int fboId = rlLoadFramebuffer(width, height);
//
//    glBindFramebuffer(GL_FRAMEBUFFER, fboId);
//    glBindTexture(GL_TEXTURE_2D, 0);
//
//    // Attach our texture to FBO
//    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, id, 0);
//
//    // We read data as RGBA because FBO texture is configured as RGBA, despite binding another texture format
//    pixels = (unsigned char *RL_MALLOC(rlGetPixelDataSize(width, height, RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8));
//    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
//
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//
//    // Clean up temporal fbo
//    rlUnloadFramebuffer(fboId);
//#endif
//
//    return pixels;
//}
//
//// Read screen pixel data (color buffer)
//unsigned char *lReadScreenPixels(int width, int height)
//{
//    unsigned char *creenData = (unsigned char *RL_CALLOC(width*eight*, sizeof(unsigned char));
//
//    // NOTE 1: glReadPixels returns image flipped vertically -> (0,0) is the bottom left corner of the framebuffer
//    // NOTE 2: We are getting alpha channel! Be careful, it can be transparent if not cleared properly!
//    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, screenData);
//
//    // Flip image vertically!
//    unsigned char *mgData = (unsigned char *RL_MALLOC(width*eight**izeof(unsigned char));
//
//    for (int y = height - 1; y >= 0; y--)
//    {
//        for (int x = 0; x < (width*); x++)
//        {
//            imgData[((height - 1) - y)*idth* + x] = screenData[(y*idth*) + x];  // Flip line
//
//            // Set alpha component value to 255 (no trasparent image retrieval)
//            // NOTE: Alpha value has already been applied to RGB in framebuffer, we don't need it!
//            if (((x + 1)%4) == 0) imgData[((height - 1) - y)*idth* + x] = 255;
//        }
//    }
//
//    RL_FREE(screenData);
//
//    return imgData;     // NOTE: image data should be freed
//}
//
//// Framebuffer management (fbo)
////-----------------------------------------------------------------------------------------
//// Load a framebuffer to be used for rendering
//// NOTE: No textures attached
//unsigned int rlLoadFramebuffer(int width, int height)
//{
//    unsigned int fboId = 0;
//
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    glGenFramebuffers(1, &fboId);       // Create the framebuffer object
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);   // Unbind any framebuffer
//#endif
//
//    return fboId;
//}
//
//// Attach color buffer texture to an fbo (unloads previous attachment)
//// NOTE: Attach type: 0-Color, 1-Depth renderbuffer, 2-Depth texture
//void rlFramebufferAttach(unsigned int fboId, unsigned int texId, int attachType, int texType, int mipLevel)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    glBindFramebuffer(GL_FRAMEBUFFER, fboId);
//
//    switch (attachType)
//    {
//        case RL_ATTACHMENT_COLOR_CHANNEL0:
//        case RL_ATTACHMENT_COLOR_CHANNEL1:
//        case RL_ATTACHMENT_COLOR_CHANNEL2:
//        case RL_ATTACHMENT_COLOR_CHANNEL3:
//        case RL_ATTACHMENT_COLOR_CHANNEL4:
//        case RL_ATTACHMENT_COLOR_CHANNEL5:
//        case RL_ATTACHMENT_COLOR_CHANNEL6:
//        case RL_ATTACHMENT_COLOR_CHANNEL7:
//        {
//            if (texType == RL_ATTACHMENT_TEXTURE2D) glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + attachType, GL_TEXTURE_2D, texId, mipLevel);
//            else if (texType == RL_ATTACHMENT_RENDERBUFFER) glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + attachType, GL_RENDERBUFFER, texId);
//            else if (texType >= RL_ATTACHMENT_CUBEMAP_POSITIVE_X) glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + attachType, GL_TEXTURE_CUBE_MAP_POSITIVE_X + texType, texId, mipLevel);
//
//        } break;
//        case RL_ATTACHMENT_DEPTH:
//        {
//            if (texType == RL_ATTACHMENT_TEXTURE2D) glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, texId, mipLevel);
//            else if (texType == RL_ATTACHMENT_RENDERBUFFER)  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, texId);
//
//        } break;
//        case RL_ATTACHMENT_STENCIL:
//        {
//            if (texType == RL_ATTACHMENT_TEXTURE2D) glFramebufferTexture2D(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_TEXTURE_2D, texId, mipLevel);
//            else if (texType == RL_ATTACHMENT_RENDERBUFFER)  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, texId);
//
//        } break;
//        default: break;
//    }
//
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//#endif
//}
//
//// Verify render texture is complete
//bool rlFramebufferComplete(unsigned int id)
//{
//    bool result = false;
//
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    glBindFramebuffer(GL_FRAMEBUFFER, id);
//
//    GLpub enum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//
//    if (status != GL_FRAMEBUFFER_COMPLETE)
//    {
//        switch (status)
//        {
//            case GL_FRAMEBUFFER_UNSUPPORTED: TRACELOG(RL_LOG_WARNING, "FBO: [ID %i] Framebuffer is unsupported", id); break;
//            case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT: TRACELOG(RL_LOG_WARNING, "FBO: [ID %i] Framebuffer has incomplete attachment", id); break;
//#if defined(GRAPHICS_API_OPENGL_ES2)
//            case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS: TRACELOG(RL_LOG_WARNING, "FBO: [ID %i] Framebuffer has incomplete dimensions", id); break;
//#endif
//            case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT: TRACELOG(RL_LOG_WARNING, "FBO: [ID %i] Framebuffer has a missing attachment", id); break;
//            default: break;
//        }
//    }
//
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//
//    result = (status == GL_FRAMEBUFFER_COMPLETE);
//#endif
//
//    return result;
//}
//
//// Unload framebuffer from GPU memory
//// NOTE: All attached textures/cubemaps/renderbuffers are also deleted
//void rlUnloadFramebuffer(unsigned int id)
//{
//#if (defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)) && defined(RLGL_RENDER_TEXTURES_HINT)
//    // Query depth attachment to automatically delete texture/renderbuffer
//    int depthType = 0, depthId = 0;
//    glBindFramebuffer(GL_FRAMEBUFFER, id);   // Bind framebuffer to query depth texture type
//    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, &depthType);
//
//    // TODO: Review warning retrieving object name in WebGL
//    // WARNING: WebGL: INVALID_pub enum: getFramebufferAttachmentParameter: invalid parameter name
//    // https://registry.khronos.org/webgl/specs/latest/1.0/
//    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, &depthId);
//
//    unsigned int depthIdU = (unsigned int)depthId;
//    if (depthType == GL_RENDERBUFFER) glDeleteRenderbuffers(1, &depthIdU);
//    else if (depthType == GL_TEXTURE) glDeleteTextures(1, &depthIdU);
//
//    // NOTE: If a texture object is deleted while its image is attached to the *urrently bound*framebuffer,
//    // the texture image is automatically detached from the currently bound framebuffer.
//
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//    glDeleteFramebuffers(1, &id);
//
//    TRACELOG(RL_LOG_INFO, "FBO: [ID %i] Unloaded framebuffer from VRAM (GPU)", id);
//#endif
//}
//
//// Vertex data management
////-----------------------------------------------------------------------------------------
//// Load a new attributes buffer
//unsigned int rlLoadVertexBuffer(const void *uffer, int size, bool dynamic)
//{
//    unsigned int id = 0;
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glGenBuffers(1, &id);
//    glBindBuffer(GL_ARRAY_BUFFER, id);
//    glBufferData(GL_ARRAY_BUFFER, size, buffer, dynamic? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);
//#endif
//
//    return id;
//}
//
//// Load a new attributes element buffer
//unsigned int rlLoadVertexBufferElement(const void *uffer, int size, bool dynamic)
//{
//    unsigned int id = 0;
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glGenBuffers(1, &id);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, buffer, dynamic? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);
//#endif
//
//    return id;
//}
//
//// Enable vertex buffer (VBO)
//void rlEnableVertexBuffer(unsigned int id)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindBuffer(GL_ARRAY_BUFFER, id);
//#endif
//}
//
//// Disable vertex buffer (VBO)
//void rlDisableVertexBuffer(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
//#endif
//}
//
//// Enable vertex buffer element (VBO element)
//void rlEnableVertexBufferElement(unsigned int id)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
//#endif
//}
//
//// Disable vertex buffer element (VBO element)
//void rlDisableVertexBufferElement(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
//#endif
//}
//
//// Update vertex buffer with new data
//// NOTE: dataSize and offset must be provided in bytes
//void rlUpdateVertexBuffer(unsigned int id, const void *ata, int dataSize, int offset)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindBuffer(GL_ARRAY_BUFFER, id);
//    glBufferSubData(GL_ARRAY_BUFFER, offset, dataSize, data);
//#endif
//}
//
//// Update vertex buffer elements with new data
//// NOTE: dataSize and offset must be provided in bytes
//void rlUpdateVertexBufferElements(unsigned int id, const void *ata, int dataSize, int offset)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
//    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, offset, dataSize, data);
//#endif
//}
//
//// Enable vertex array object (VAO)
//bool rlEnableVertexArray(unsigned int vaoId)
//{
//    bool result = false;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if (RLGL.ExtSupported.vao)
//    {
//        glBindVertexArray(vaoId);
//        result = true;
//    }
//#endif
//    return result;
//}
//
//// Disable vertex array object (VAO)
//void rlDisableVertexArray(void)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if (RLGL.ExtSupported.vao) glBindVertexArray(0);
//#endif
//}
//
//// Enable vertex attribute index
//void rlEnableVertexAttribute(unsigned int index)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glEnableVertexAttribArray(index);
//#endif
//}
//
//// Disable vertex attribute index
//void rlDisableVertexAttribute(unsigned int index)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glDisableVertexAttribArray(index);
//#endif
//}
//
//// Draw vertex array
//void rlDrawVertexArray(int offset, int count)
//{
//    glDrawArrays(GL_TRIANGLES, offset, count);
//}
//
//// Draw vertex array elements
//void rlDrawVertexArrayElements(int offset, int count, const void *uffer)
//{
//    // NOTE: Added pointer math separately from function to avoid UBSAN complaining
//    unsigned short *ufferPtr = (unsigned short *buffer;
//    if (offset > 0) bufferPtr += offset;
//
//    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_SHORT, (const unsigned short *bufferPtr);
//}
//
//// Draw vertex array instanced
//void rlDrawVertexArrayInstanced(int offset, int count, int instances)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glDrawArraysInstanced(GL_TRIANGLES, 0, count, instances);
//#endif
//}
//
//// Draw vertex array elements instanced
//void rlDrawVertexArrayElementsInstanced(int offset, int count, const void *uffer, int instances)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    // NOTE: Added pointer math separately from function to avoid UBSAN complaining
//    unsigned short *ufferPtr = (unsigned short *buffer;
//    if (offset > 0) bufferPtr += offset;
//
//    glDrawElementsInstanced(GL_TRIANGLES, count, GL_UNSIGNED_SHORT, (const unsigned short *bufferPtr, instances);
//#endif
//}
//
//#if defined(GRAPHICS_API_OPENGL_11)
//// Enable vertex state pointer
//void rlEnableStatePointer(int vertexAttribType, void *uffer)
//{
//    if (buffer != NULL) glEnableClientState(vertexAttribType);
//    switch (vertexAttribType)
//    {
//        case GL_VERTEX_ARRAY: glVertexPointer(3, GL_FLOAT, 0, buffer); break;
//        case GL_TEXTURE_COORD_ARRAY: glTexCoordPointer(2, GL_FLOAT, 0, buffer); break;
//        case GL_NORMAL_ARRAY: if (buffer != NULL) glNormalPointer(GL_FLOAT, 0, buffer); break;
//        case GL_COLOR_ARRAY: if (buffer != NULL) glColorPointer(4, GL_UNSIGNED_BYTE, 0, buffer); break;
//        //case GL_INDEX_ARRAY: if (buffer != NULL) glIndexPointer(GL_SHORT, 0, buffer); break; // Indexed colors
//        default: break;
//    }
//}
//
//// Disable vertex state pointer
//void rlDisableStatePointer(int vertexAttribType)
//{
//    glDisableClientState(vertexAttribType);
//}
//#endif
//
//// Load vertex array object (VAO)
//unsigned int rlLoadVertexArray(void)
//{
//    unsigned int vaoId = 0;
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if (RLGL.ExtSupported.vao)
//    {
//        glGenVertexArrays(1, &vaoId);
//    }
//#endif
//    return vaoId;
//}
//
//// Set vertex attribute
//void rlSetVertexAttribute(unsigned int index, int compSize, int type, bool normalized, int stride, const void *ointer)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glVertexAttribPointer(index, compSize, type, normalized, stride, pointer);
//#endif
//}
//
//// Set vertex attribute divisor
//void rlSetVertexAttributeDivisor(unsigned int index, int divisor)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glVertexAttribDivisor(index, divisor);
//#endif
//}
//
//// Unload vertex array object (VAO)
//void rlUnloadVertexArray(unsigned int vaoId)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    if (RLGL.ExtSupported.vao)
//    {
//        glBindVertexArray(0);
//        glDeleteVertexArrays(1, &vaoId);
//        TRACELOG(RL_LOG_INFO, "VAO: [ID %i] Unloaded vertex array data from VRAM (GPU)", vaoId);
//    }
//#endif
//}
//
//// Unload vertex buffer (VBO)
//void rlUnloadVertexBuffer(unsigned int vboId)
//{
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    glDeleteBuffers(1, &vboId);
//    //TRACELOG(RL_LOG_INFO, "VBO: Unloaded vertex data from VRAM (GPU)");
//#endif
//}
//
//// Shaders management
////-----------------------------------------------------------------------------------------------
//// Load shader from code strings
//// NOTE: If shader string is NULL, using default vertex/fragment shaders
//unsigned int rlLoadShaderCode(const char *sCode, const char *sCode)
//{
//    unsigned int id = 0;
//
//#if defined(GRAPHICS_API_OPENGL_33) || defined(GRAPHICS_API_OPENGL_ES2)
//    unsigned int vertexShaderId = 0;
//    unsigned int fragmentShaderId = 0;
//
//    // Compile vertex shader (if provided)
//    if (vsCode != NULL) vertexShaderId = rlCompileShader(vsCode, GL_VERTEX_SHADER);
//    // In case no vertex shader was provided or compilation failed, we use default vertex shader
//    if (vertexShaderId == 0) vertexShaderId = RLGL.State.defaultVShaderId;
//
//    // Compile fragment shader (if provided)
//    if (fsCode != NULL) fragmentShaderId = rlCompileShader(fsCode, GL_FRAGMENT_SHADER);
//    // In case no fragment shader was provided or compilation failed, we use default fragment shader
//    if (fragmentShaderId == 0) fragmentShaderId = RLGL.State.defaultFShaderId;
//
//    // In case vertex and fragment shader are the default ones, no need to recompile, we can just assign the default shader program id
//    if ((vertexShaderId == RLGL.State.defaultVShaderId) && (fragmentShaderId == RLGL.State.defaultFShaderId)) id = RLGL.State.defaultShaderId;
//    else
//    {
//        // One of or both shader are new, we need to compile a new shader program
//        id = rlLoadShaderProgram(vertexShaderId, fragmentShaderId);
//
//        // We can detach and delete vertex/fragment shaders (if not default ones)
//        // NOTE: We detach shader before deletion to make sure memory is freed
//        if (vertexShaderId != RLGL.State.defaultVShaderId)
//        {
//            // WARNING: Shader program linkage could fail and returned id is 0
//            if (id > 0) glDetachShader(id, vertexShaderId);
//            glDeleteShader(vertexShaderId);
//        }
//        if (fragmentShaderId != RLGL.State.defaultFShaderId)
//        {
//            // WARNING: Shader program linkage could fail and returned id is 0
//            if (id > 0) glDetachShader(id, fragmentShaderId);
//            glDeleteShader(fragmentShaderId);
//        }
//
//        // In case shader program loading failed, we assign default shader
//        if (id == 0)
//        {
//            // In case shader loading fails, we return the default shader
//            TRACELOG(RL_LOG_WARNING, "SHADER: Failed to load custom shader code, using default shader");
//            id = RLGL.State.defaultShaderId;
//        }
//        /*        else
//        {
//            // Get available shader uniforms
//            // NOTE: This information is useful for debug...
//            int uniformCount = -1;
//            glGetProgramiv(id, GL_ACTIVE_UNIFORMS, &uniformCount);
//
//            for (int i = 0; i < uniformCount; i++)
//            {
//                int namelen = -1;
//                int num = -1;
//                char name[256] = { 0 };     // Assume no variable names longer than 256
//                GLpub enum type = GL_ZERO;
//
//                // Get the name of the uniforms
//                glGetActiveUniform(id, i, sizeof(name) - 1, &namelen, &num, &type, name);
//
//                name[namelen] = 0;
//                TRACELOGD("SHADER: [ID %i] Active uniform (%s) set at location: %i", id, name, glGetUniformLocation(id, name));
//            }
//        }
//        
// struct Matrix { 
// 	m0 f32
// 	m4 f32
// 	m8 f32
// 	m12 f32
// 	m1 f32
// 	m5 f32
// 	m9 f32
// 	m13 f32
// 	m2 f32
// 	m6 f32
// 	m10 f32
// 	m14 f32
// 	m3 f32
// 	m7 f32
// 	m11 f32
// 	m15 f32
// }
@[typedef]
struct C.rlVertexBuffer { 
pub mut:
	elementCount int
	vertices &f32
	texcoords &f32
	colors &u8
	indices &u32
	vaoId u32
	vboId [4]u32
}

pub type RlVertexBuffer = C.rlVertexBuffer

@[typedef]
struct C.rlDrawCall { 
pub mut:
	mode int
	vertexCount int
	vertexAlignment int
	textureId u32
}

pub type RlDrawCall = C.rlDrawCall

@[typedef]
struct C.rlRenderBatch {
pub mut:
	bufferCount int
	currentBuffer int
	vertexBuffer &RlVertexBuffer
	draws &RlDrawCall
	drawCounter int
	currentDepth f32
}

pub type RlRenderBatch = C.rlRenderBatch

pub enum RlGlVersion {
	rl_opengl_11 = 1
	rl_opengl_21
	rl_opengl_33
	rl_opengl_43
	rl_opengl_es_20
	rl_opengl_es_30
}

pub enum RlTraceLogLevel {
	rl_log_all = 0
	rl_log_trace
	rl_log_debug
	rl_log_info
	rl_log_warning
	rl_log_error
	rl_log_fatal
	rl_log_none
}

pub enum RlPixelFormat {
	rl_pixelformat_uncompressed_grayscale = 1
	rl_pixelformat_uncompressed_gray_alpha
	rl_pixelformat_uncompressed_r5_g6_b5
	rl_pixelformat_uncompressed_r8_g8_b8
	rl_pixelformat_uncompressed_r5_g5_b5_a1
	rl_pixelformat_uncompressed_r4_g4_b4_a4
	rl_pixelformat_uncompressed_r8_g8_b8_a8
	rl_pixelformat_uncompressed_r32
	rl_pixelformat_uncompressed_r32_g32_b32
	rl_pixelformat_uncompressed_r32_g32_b32_a32
	rl_pixelformat_uncompressed_r16
	rl_pixelformat_uncompressed_r16_g16_b16
	rl_pixelformat_uncompressed_r16_g16_b16_a16
	rl_pixelformat_compressed_dxt_1_rgb
	rl_pixelformat_compressed_dxt_1_rgba
	rl_pixelformat_compressed_dxt_3_rgba
	rl_pixelformat_compressed_dxt_5_rgba
	rl_pixelformat_compressed_etc_1_rgb
	rl_pixelformat_compressed_etc_2_rgb
	rl_pixelformat_compressed_etc_2_eac_rgba
	rl_pixelformat_compressed_pvrt_rgb
	rl_pixelformat_compressed_pvrt_rgba
	rl_pixelformat_compressed_astc_4x4_rgba
	rl_pixelformat_compressed_astc_8x8_rgba
}

pub enum RlTextureFilter {
	rl_texture_filter_point = 0
	rl_texture_filter_bilinear
	rl_texture_filter_trilinear
	rl_texture_filter_anisotropic_4_x
	rl_texture_filter_anisotropic_8_x
	rl_texture_filter_anisotropic_16_x
}

pub enum RlBlendMode {
	rl_blend_alpha = 0
	rl_blend_additive
	rl_blend_multiplied
	rl_blend_add_colors
	rl_blend_subtract_colors
	rl_blend_alpha_premultiply
	rl_blend_custom
	rl_blend_custom_separate
}

pub enum RlShaderLocationIndex {
	rl_shader_loc_vertex_position = 0
	rl_shader_loc_vertex_texcoord_01
	rl_shader_loc_vertex_texcoord_02
	rl_shader_loc_vertex_normal
	rl_shader_loc_vertex_tangent
	rl_shader_loc_vertex_color
	rl_shader_loc_matrix_mvp
	rl_shader_loc_matrix_view
	rl_shader_loc_matrix_projection
	rl_shader_loc_matrix_model
	rl_shader_loc_matrix_normal
	rl_shader_loc_vector_view
	rl_shader_loc_color_diffuse
	rl_shader_loc_color_specular
	rl_shader_loc_color_ambient
	rl_shader_loc_map_albedo
	rl_shader_loc_map_metalness
	rl_shader_loc_map_normal
	rl_shader_loc_map_roughness
	rl_shader_loc_map_occlusion
	rl_shader_loc_map_emission
	rl_shader_loc_map_height
	rl_shader_loc_map_cubemap
	rl_shader_loc_map_irradiance
	rl_shader_loc_map_prefilter
	rl_shader_loc_map_brdf
}

pub enum RlShaderUniformDataType {
	rl_shader_uniform_float = 0
	rl_shader_uniform_vec_2
	rl_shader_uniform_vec_3
	rl_shader_uniform_vec_4
	rl_shader_uniform_int
	rl_shader_uniform_ivec_2
	rl_shader_uniform_ivec_3
	rl_shader_uniform_ivec_4
	rl_shader_uniform_sampler_2_d
}

pub enum RlShaderAttributeDataType {
	rl_shader_attrib_float = 0
	rl_shader_attrib_vec_2
	rl_shader_attrib_vec_3
	rl_shader_attrib_vec_4
}

pub enum RlFramebufferAttachType {
	rl_attachment_color_channel_0 = 0
	rl_attachment_color_channel_1 = 1
	rl_attachment_color_channel_2 = 2
	rl_attachment_color_channel_3 = 3
	rl_attachment_color_channel_4 = 4
	rl_attachment_color_channel_5 = 5
	rl_attachment_color_channel_6 = 6
	rl_attachment_color_channel_7 = 7
	rl_attachment_depth = 100
	rl_attachment_stencil = 200
}

pub enum RlFramebufferAttachTextureType {
	rl_attachment_cubemap_positive_x = 0
	rl_attachment_cubemap_negative_x = 1
	rl_attachment_cubemap_positive_y = 2
	rl_attachment_cubemap_negative_y = 3
	rl_attachment_cubemap_positive_z = 4
	rl_attachment_cubemap_negative_z = 5
	rl_attachment_texture_2_d = 100
	rl_attachment_renderbuffer = 200
}

pub enum RlCullMode {
	rl_cull_face_front = 0
	rl_cull_face_back
}

fn C.rlMatrixMode(mode int)
@[inline]
pub fn rl_matrix_mode(mode int) {
	C.rlMatrixMode(mode)
}

fn C.rlPushMatrix()
@[inline]
pub fn rl_push_matrix() {
	C.rlPushMatrix()
}

fn C.rlPopMatrix()
@[inline]
pub fn rl_pop_matrix() {
	C.rlPopMatrix()
}

fn C.rlLoadIdentity()
@[inline]
pub fn rl_load_identity() {
	C.rlLoadIdentity()
}

fn C.rlTranslatef(x f32, y f32, z f32)
@[inline]
pub fn rl_translatef(x f32, y f32, z f32) {
	C.rlTranslatef(x, y, z)
}

fn C.rlRotatef(angle f32, x f32, y f32, z f32)
@[inline]
pub fn rl_rotatef(angle f32, x f32, y f32, z f32) {
	C.rlRotatef(angle, x, y, z)
}

fn C.rlScalef(x f32, y f32, z f32)
@[inline]
pub fn rl_scalef(x f32, y f32, z f32) {
	C.rlScalef(x, y, z)
}

fn C.rlMultMatrixf(matf &f32)
@[inline]
pub fn rl_mult_matrixf(matf &f32) {
	C.rlMultMatrixf(matf)
}

fn C.rlFrustum(left f64, right f64, bottom f64, top f64, znear f64, zfar f64)
@[inline]
pub fn rl_frustum(left f64, right f64, bottom f64, top f64, znear f64, zfar f64) {
	C.rlFrustum(left, right, bottom, top, znear, zfar)
}

fn C.rlOrtho(left f64, right f64, bottom f64, top f64, znear f64, zfar f64)
@[inline]
pub fn rl_ortho(left f64, right f64, bottom f64, top f64, znear f64, zfar f64) {
	C.rlOrtho(left, right, bottom, top, znear, zfar)
}

fn C.rlViewport(x int, y int, width int, height int)
@[inline]
pub fn rl_viewport(x int, y int, width int, height int) {
	C.rlViewport(x, y, width, height)
}

fn C.rlBegin(mode int)
@[inline]
pub fn rl_begin(mode int) {
	C.rlBegin(mode)
}

fn C.rlEnd()
@[inline]
pub fn rl_end() {
	C.rlEnd()
}

fn C.rlVertex2i(x int, y int)
@[inline]
pub fn rl_vertex2i(x int, y int) {
	C.rlVertex2i(x, y)
}

fn C.rlVertex2f(x f32, y f32)
@[inline]
pub fn rl_vertex2f(x f32, y f32) {
	C.rlVertex2f(x, y)
}

fn C.rlVertex3f(x f32, y f32, z f32)
@[inline]
pub fn rl_vertex3f(x f32, y f32, z f32) {
	C.rlVertex3f(x, y, z)
}

fn C.rlTexCoord2f(x f32, y f32)
@[inline]
pub fn rl_tex_coord2f(x f32, y f32) {
	C.rlTexCoord2f(x, y)
}

fn C.rlNormal3f(x f32, y f32, z f32)
@[inline]
pub fn rl_normal3f(x f32, y f32, z f32) {
	C.rlNormal3f(x, y, z)
}

fn C.rlColor4ub(r u8, g u8, b u8, a u8)
@[inline]
pub fn rl_color4ub(r u8, g u8, b u8, a u8) {
	C.rlColor4ub(r, g, b, a)
}

fn C.rlColor3f(x f32, y f32, z f32)
@[inline]
pub fn rl_color3f(x f32, y f32, z f32) {
	C.rlColor3f(x, y, z)
}

fn C.rlColor4f(x f32, y f32, z f32, w f32)
@[inline]
pub fn rl_color4f(x f32, y f32, z f32, w f32) {
	C.rlColor4f(x, y, z, w)
}

fn C.rlEnableVertexArray(vao_id u32) bool
@[inline]
pub fn rl_enable_vertex_array(vao_id u32) bool {
	return C.rlEnableVertexArray(vao_id)
}

fn C.rlDisableVertexArray()
@[inline]
pub fn rl_disable_vertex_array() {
	C.rlDisableVertexArray()
}

fn C.rlEnableVertexBuffer(id u32)
@[inline]
pub fn rl_enable_vertex_buffer(id u32) {
	C.rlEnableVertexBuffer(id)
}

fn C.rlDisableVertexBuffer()
@[inline]
pub fn rl_disable_vertex_buffer() {
	C.rlDisableVertexBuffer()
}

fn C.rlEnableVertexBufferElement(id u32)
@[inline]
pub fn rl_enable_vertex_buffer_element(id u32) {
	C.rlEnableVertexBufferElement(id)
}

fn C.rlDisableVertexBufferElement()
@[inline]
pub fn rl_disable_vertex_buffer_element() {
	C.rlDisableVertexBufferElement()
}

fn C.rlEnableVertexAttribute(index u32)
@[inline]
pub fn rl_enable_vertex_attribute(index u32) {
	C.rlEnableVertexAttribute(index)
}

fn C.rlDisableVertexAttribute(index u32)
@[inline]
pub fn rl_disable_vertex_attribute(index u32) {
	C.rlDisableVertexAttribute(index)
}

fn C.rlActiveTextureSlot(slot int)
@[inline]
pub fn rl_active_texture_slot(slot int) {
	C.rlActiveTextureSlot(slot)
}

fn C.rlEnableTexture(id u32)
@[inline]
pub fn rl_enable_texture(id u32) {
	C.rlEnableTexture(id)
}

fn C.rlDisableTexture()
@[inline]
pub fn rl_disable_texture() {
	C.rlDisableTexture()
}

fn C.rlEnableTextureCubemap(id u32)
@[inline]
pub fn rl_enable_texture_cubemap(id u32) {
	C.rlEnableTextureCubemap(id)
}

fn C.rlDisableTextureCubemap()
@[inline]
pub fn rl_disable_texture_cubemap() {
	C.rlDisableTextureCubemap()
}

fn C.rlTextureParameters(id u32, param int, value int)
@[inline]
pub fn rl_texture_parameters(id u32, param int, value int) {
	C.rlTextureParameters(id, param, value)
}

fn C.rlCubemapParameters(id u32, param int, value int)
@[inline]
pub fn rl_cubemap_parameters(id u32, param int, value int) {
	C.rlCubemapParameters(id, param, value)
}

fn C.rlEnableShader(id u32)
@[inline]
pub fn rl_enable_shader(id u32) {
	C.rlEnableShader(id)
}

fn C.rlDisableShader()
@[inline]
pub fn rl_disable_shader() {
	C.rlDisableShader()
}

fn C.rlEnableFramebuffer(id u32)
@[inline]
pub fn rl_enable_framebuffer(id u32) {
	C.rlEnableFramebuffer(id)
}

fn C.rlDisableFramebuffer()
@[inline]
pub fn rl_disable_framebuffer() {
	C.rlDisableFramebuffer()
}

fn C.rlActiveDrawBuffers(count int)
@[inline]
pub fn rl_active_draw_buffers(count int) {
	C.rlActiveDrawBuffers(count)
}

fn C.rlBlitFramebuffer(src_x int, src_y int, src_width int, src_height int, dst_x int, dst_y int, dst_width int, dst_height int, buffer_mask int)
@[inline]
pub fn rl_blit_framebuffer(src_x int, src_y int, src_width int, src_height int, dst_x int, dst_y int, dst_width int, dst_height int, buffer_mask int) {
	C.rlBlitFramebuffer(src_x, src_y, src_width, src_height, dst_x, dst_y, dst_width, dst_height, buffer_mask)
}

fn C.rlEnableColorBlend()
@[inline]
pub fn rl_enable_color_blend() {
	C.rlEnableColorBlend()
}

fn C.rlDisableColorBlend()
@[inline]
pub fn rl_disable_color_blend() {
	C.rlDisableColorBlend()
}

fn C.rlEnableDepthTest()
@[inline]
pub fn rl_enable_depth_test() {
	C.rlEnableDepthTest()
}

fn C.rlDisableDepthTest()
@[inline]
pub fn rl_disable_depth_test() {
	C.rlDisableDepthTest()
}

fn C.rlEnableDepthMask()
@[inline]
pub fn rl_enable_depth_mask() {
	C.rlEnableDepthMask()
}

fn C.rlDisableDepthMask()
@[inline]
pub fn rl_disable_depth_mask() {
	C.rlDisableDepthMask()
}

fn C.rlEnableBackfaceCulling()
@[inline]
pub fn rl_enable_backface_culling() {
	C.rlEnableBackfaceCulling()
}

fn C.rlDisableBackfaceCulling()
@[inline]
pub fn rl_disable_backface_culling() {
	C.rlDisableBackfaceCulling()
}

fn C.rlSetCullFace(mode int)
@[inline]
pub fn rl_set_cull_face(mode int) {
	C.rlSetCullFace(mode)
}

fn C.rlEnableScissorTest()
@[inline]
pub fn rl_enable_scissor_test() {
	C.rlEnableScissorTest()
}

fn C.rlDisableScissorTest()
@[inline]
pub fn rl_disable_scissor_test() {
	C.rlDisableScissorTest()
}

fn C.rlScissor(x int, y int, width int, height int)
@[inline]
pub fn rl_scissor(x int, y int, width int, height int) {
	C.rlScissor(x, y, width, height)
}

fn C.rlEnableWireMode()
@[inline]
pub fn rl_enable_wire_mode() {
	C.rlEnableWireMode()
}

fn C.rlEnablePointMode()
@[inline]
pub fn rl_enable_point_mode() {
	C.rlEnablePointMode()
}

fn C.rlDisableWireMode()
@[inline]
pub fn rl_disable_wire_mode() {
	C.rlDisableWireMode()
}

fn C.rlSetLineWidth(width f32)
@[inline]
pub fn rl_set_line_width(width f32) {
	C.rlSetLineWidth(width)
}

fn C.rlGetLineWidth() f32
@[inline]
pub fn rl_get_line_width() f32 {
	return C.rlGetLineWidth()
}

fn C.rlEnableSmoothLines()
@[inline]
pub fn rl_enable_smooth_lines() {
	C.rlEnableSmoothLines()
}

fn C.rlDisableSmoothLines()
@[inline]
pub fn rl_disable_smooth_lines() {
	C.rlDisableSmoothLines()
}

fn C.rlEnableStereoRender()
@[inline]
pub fn rl_enable_stereo_render() {
	C.rlEnableStereoRender()
}

fn C.rlDisableStereoRender()
@[inline]
pub fn rl_disable_stereo_render() {
	C.rlDisableStereoRender()
}

fn C.rlIsStereoRenderEnabled() bool
@[inline]
pub fn rl_is_stereo_render_enabled() bool {
	return C.rlIsStereoRenderEnabled()
}

fn C.rlClearColor(r u8, g u8, b u8, a u8)
@[inline]
pub fn rl_clear_color(r u8, g u8, b u8, a u8) {
	C.rlClearColor(r, g, b, a)
}

fn C.rlClearScreenBuffers()
@[inline]
pub fn rl_clear_screen_buffers() {
	C.rlClearScreenBuffers()
}

fn C.rlCheckErrors()
@[inline]
pub fn rl_check_errors() {
	C.rlCheckErrors()
}

fn C.rlSetBlendMode(mode int)
@[inline]
pub fn rl_set_blend_mode(mode int) {
	C.rlSetBlendMode(mode)
}

fn C.rlSetBlendFactors(gl_src_factor int, gl_dst_factor int, gl_equation int)
@[inline]
pub fn rl_set_blend_factors(gl_src_factor int, gl_dst_factor int, gl_equation int) {
	C.rlSetBlendFactors(gl_src_factor, gl_dst_factor, gl_equation)
}
@[inline]
fn C.rlSetBlendFactorsSeparate(gl_src_rgb int, gl_dst_rgb int, gl_src_alpha int, gl_dst_alpha int, gl_eq_rgb int, gl_eq_alpha int)
@[inline]
pub fn rl_set_blend_factors_separate(gl_src_rgb int, gl_dst_rgb int, gl_src_alpha int, gl_dst_alpha int, gl_eq_rgb int, gl_eq_alpha int) {
	C.rlSetBlendFactorsSeparate(gl_src_rgb, gl_dst_rgb, gl_src_alpha, gl_dst_alpha, gl_eq_rgb, gl_eq_alpha)
}

fn C.rlglInit(width int, height int)
@[inline]
pub fn rlgl_init(width int, height int) {
	C.rlglInit(width, height)
}

fn C.rlglClose()
@[inline]
pub fn rlgl_close() {
	C.rlglClose()
}

fn C.rlLoadExtensions(loader voidptr)
@[inline]
pub fn rl_load_extensions(loader voidptr) {
	C.rlLoadExtensions(loader)
}

fn C.rlGetVersion() int
@[inline]
pub fn rl_get_version() int {
	return C.rlGetVersion()
}

fn C.rlSetFramebufferWidth(width int)
@[inline]
pub fn rl_set_framebuffer_width(width int) {
	C.rlSetFramebufferWidth(width)
}

fn C.rlGetFramebufferWidth() int
@[inline]
pub fn rl_get_framebuffer_width() int {
	return C.rlGetFramebufferWidth()
}

fn C.rlSetFramebufferHeight(height int)
@[inline]
pub fn rl_set_framebuffer_height(height int) {
	C.rlSetFramebufferHeight(height)
}

fn C.rlGetFramebufferHeight() int
@[inline]
pub fn rl_get_framebuffer_height() int {
	return C.rlGetFramebufferHeight()
}

fn C.rlGetTextureIdDefault() u32
@[inline]
pub fn rl_get_texture_id_default() u32 {
	return C.rlGetTextureIdDefault()
}

fn C.rlGetShaderIdDefault() u32
@[inline]
pub fn rl_get_shader_id_default() u32 {
	return C.rlGetShaderIdDefault()
}

fn C.rlGetShaderLocsDefault() &int
@[inline]
pub fn rl_get_shader_locs_default() &int {
	return C.rlGetShaderLocsDefault()
}

fn C.rlLoadRenderBatch(num_buffers int, buffer_elements int) RlRenderBatch
@[inline]
pub fn rl_load_render_batch(num_buffers int, buffer_elements int) RlRenderBatch {
	return C.rlLoadRenderBatch(num_buffers, buffer_elements)
}

fn C.rlUnloadRenderBatch(batch RlRenderBatch)
@[inline]
pub fn rl_unload_render_batch(batch RlRenderBatch) {
	C.rlUnloadRenderBatch(batch)
}

fn C.rlDrawRenderBatch(batch &RlRenderBatch)
@[inline]
pub fn rl_draw_render_batch(batch &RlRenderBatch) {
	C.rlDrawRenderBatch(batch)
}

fn C.rlSetRenderBatchActive(batch &RlRenderBatch)
@[inline]
pub fn rl_set_render_batch_active(batch &RlRenderBatch) {
	C.rlSetRenderBatchActive(batch)
}

fn C.rlDrawRenderBatchActive()
@[inline]
pub fn rl_draw_render_batch_active() {
	C.rlDrawRenderBatchActive()
}

fn C.rlCheckRenderBatchLimit(v_count int) bool
@[inline]
pub fn rl_check_render_batch_limit(v_count int) bool {
	return C.rlCheckRenderBatchLimit(v_count)
}

fn C.rlSetTexture(id u32)
@[inline]
pub fn rl_set_texture(id u32) {
	C.rlSetTexture(id)
}

fn C.rlLoadVertexArray() u32
@[inline]
pub fn rl_load_vertex_array() u32 {
	return C.rlLoadVertexArray()
}

fn C.rlLoadVertexBuffer(buffer voidptr, size int, dynamic bool) u32
@[inline]
pub fn rl_load_vertex_buffer(buffer voidptr, size int, dynamic bool) u32 {
	return C.rlLoadVertexBuffer(buffer, size, dynamic)
}

fn C.rlLoadVertexBufferElement(buffer voidptr, size int, dynamic bool) u32
@[inline]
pub fn rl_load_vertex_buffer_element(buffer voidptr, size int, dynamic bool) u32 {
	return C.rlLoadVertexBufferElement(buffer, size, dynamic)
}

fn C.rlUpdateVertexBuffer(buffer_id u32, data voidptr, data_size int, offset int)
@[inline]
pub fn rl_update_vertex_buffer(buffer_id u32, data voidptr, data_size int, offset int) {
	C.rlUpdateVertexBuffer(buffer_id, data, data_size, offset)
}

fn C.rlUpdateVertexBufferElements(id u32, data voidptr, data_size int, offset int)
@[inline]
pub fn rl_update_vertex_buffer_elements(id u32, data voidptr, data_size int, offset int) {
	C.rlUpdateVertexBufferElements(id, data, data_size, offset)
}

fn C.rlUnloadVertexArray(vao_id u32)
@[inline]
pub fn rl_unload_vertex_array(vao_id u32) {
	C.rlUnloadVertexArray(vao_id)
}

fn C.rlUnloadVertexBuffer(vbo_id u32)
@[inline]
pub fn rl_unload_vertex_buffer(vbo_id u32) {
	C.rlUnloadVertexBuffer(vbo_id)
}

fn C.rlSetVertexAttribute(index u32, comp_size int, type_ int, normalized bool, stride int, offset int)
@[inline]
pub fn rl_set_vertex_attribute(index u32, comp_size int, type_ int, normalized bool, stride int, offset int) {
	C.rlSetVertexAttribute(index, comp_size, type_, normalized, stride, offset)
}

fn C.rlSetVertexAttributeDivisor(index u32, divisor int)
@[inline]
pub fn rl_set_vertex_attribute_divisor(index u32, divisor int) {
	C.rlSetVertexAttributeDivisor(index, divisor)
}

fn C.rlSetVertexAttributeDefault(loc_index int, value voidptr, attrib_type int, count int)
@[inline]
pub fn rl_set_vertex_attribute_default(loc_index int, value voidptr, attrib_type int, count int) {
	C.rlSetVertexAttributeDefault(loc_index, value, attrib_type, count)
}

fn C.rlDrawVertexArray(offset int, count int)
@[inline]
pub fn rl_draw_vertex_array(offset int, count int) {
	C.rlDrawVertexArray(offset, count)
}

fn C.rlDrawVertexArrayElements(offset int, count int, buffer voidptr)
@[inline]
pub fn rl_draw_vertex_array_elements(offset int, count int, buffer voidptr) {
	C.rlDrawVertexArrayElements(offset, count, buffer)
}

fn C.rlDrawVertexArrayInstanced(offset int, count int, instances int)
@[inline]
pub fn rl_draw_vertex_array_instanced(offset int, count int, instances int) {
	C.rlDrawVertexArrayInstanced(offset, count, instances)
}

fn C.rlDrawVertexArrayElementsInstanced(offset int, count int, buffer voidptr, instances int)
@[inline]
pub fn rl_draw_vertex_array_elements_instanced(offset int, count int, buffer voidptr, instances int) {
	C.rlDrawVertexArrayElementsInstanced(offset, count, buffer, instances)
}

fn C.rlLoadTexture(data voidptr, width int, height int, format int, mipmap_count int) u32
@[inline]
pub fn rl_load_texture(data voidptr, width int, height int, format int, mipmap_count int) u32 {
	return C.rlLoadTexture(data, width, height, format, mipmap_count)
}

fn C.rlLoadTextureDepth(width int, height int, use_render_buffer bool) u32
@[inline]
pub fn rl_load_texture_depth(width int, height int, use_render_buffer bool) u32 {
	return C.rlLoadTextureDepth(width, height, use_render_buffer)
}

fn C.rlLoadTextureCubemap(data voidptr, size int, format int, mipmapCount int) u32
@[inline]
pub fn rl_load_texture_cubemap(data voidptr, size int, format int, mipmapCount int) u32 {
	return C.rlLoadTextureCubemap(data, size, format, mipmapCount)
}

fn C.rlUpdateTexture(id u32, offset_x int, offset_y int, width int, height int, format int, data voidptr)
@[inline]
pub fn rl_update_texture(id u32, offset_x int, offset_y int, width int, height int, format int, data voidptr) {
	C.rlUpdateTexture(id, offset_x, offset_y, width, height, format, data)
}

fn C.rlGetGlTextureFormats(format int, gl_internal_format &u32, gl_format &u32, gl_type &u32)
@[inline]
pub fn rl_get_gl_texture_formats(format int, gl_internal_format &u32, gl_format &u32, gl_type &u32) {
	C.rlGetGlTextureFormats(format, gl_internal_format, gl_format, gl_type)
}

fn C.rlGetPixelFormatName(format u32) &i8
@[inline]
pub fn rl_get_pixel_format_name(format u32) &i8 {
	return C.rlGetPixelFormatName(format)
}

fn C.rlUnloadTexture(id u32)
@[inline]
pub fn rl_unload_texture(id u32) {
	C.rlUnloadTexture(id)
}

fn C.rlGenTextureMipmaps(id u32, width int, height int, format int, mipmaps &int)

pub fn rl_gen_texture_mipmaps(id u32, width int, height int, format int, mipmaps &int) {
	C.rlGenTextureMipmaps(id, width, height, format, mipmaps)
}

fn C.rlReadTexturePixels(id u32, width int, height int, format int) voidptr
@[inline]
pub fn rl_read_texture_pixels(id u32, width int, height int, format int) voidptr {
	return C.rlReadTexturePixels(id, width, height, format)
}

fn C.rlReadScreenPixels(width int, height int) &u8
@[inline]
pub fn rl_read_screen_pixels(width int, height int) &u8 {
	return C.rlReadScreenPixels(width, height)
}

fn C.rlLoadFramebuffer() u32
@[inline]
pub fn rl_load_framebuffer() u32 {
	return C.rlLoadFramebuffer()
}

fn C.rlFramebufferAttach(fbo_id u32, tex_id u32, attach_type int, tex_type int, mip_level int)
@[inline]
pub fn rl_framebuffer_attach(fbo_id u32, tex_id u32, attach_type int, tex_type int, mip_level int) {
	C.rlFramebufferAttach(fbo_id, tex_id, attach_type, tex_type, mip_level)
}

fn C.rlFramebufferComplete(id u32) bool
@[inline]
pub fn rl_framebuffer_complete(id u32) bool {
	return C.rlFramebufferComplete(id)
}

fn C.rlUnloadFramebuffer(id u32)
@[inline]
pub fn rl_unload_framebuffer(id u32) {
	C.rlUnloadFramebuffer(id)
}

fn C.rlLoadShaderCode(vs_code &i8, fs_code &i8) u32
@[inline]
pub fn rl_load_shader_code(vs_code &i8, fs_code &i8) u32 {
	return C.rlLoadShaderCode(vs_code, fs_code)
}

fn C.rlCompileShader(shader_code &i8, type_ int) u32
@[inline]
pub fn rl_compile_shader(shader_code &i8, type_ int) u32 {
	return C.rlCompileShader(shader_code, type_)
}

fn C.rlLoadShaderProgram(v_shader_id u32, f_shader_id u32) u32
@[inline]
pub fn rl_load_shader_program(v_shader_id u32, f_shader_id u32) u32 {
	return C.rlLoadShaderProgram(v_shader_id, f_shader_id)
}

fn C.rlUnloadShaderProgram(id u32)
@[inline]
pub fn rl_unload_shader_program(id u32) {
	C.rlUnloadShaderProgram(id)
}

fn C.rlGetLocationUniform(shader_id u32, uniform_name &i8) int
@[inline]
pub fn rl_get_location_uniform(shader_id u32, uniform_name &i8) int {
	return C.rlGetLocationUniform(shader_id, uniform_name)
}

fn C.rlGetLocationAttrib(shader_id u32, attrib_name &i8) int
@[inline]
pub fn rl_get_location_attrib(shader_id u32, attrib_name &i8) int {
	return C.rlGetLocationAttrib(shader_id, attrib_name)
}

fn C.rlSetUniform(loc_index int, value voidptr, uniform_type int, count int)
@[inline]
pub fn rl_set_uniform(loc_index int, value voidptr, uniform_type int, count int) {
	C.rlSetUniform(loc_index, value, uniform_type, count)
}

fn C.rlSetUniformMatrix(loc_index int, mat Matrix)
@[inline]
pub fn rl_set_uniform_matrix(loc_index int, mat Matrix) {
	C.rlSetUniformMatrix(loc_index, mat)
}

fn C.rlSetUniformSampler(loc_index int, texture_id u32)
@[inline]
pub fn rl_set_uniform_sampler(loc_index int, texture_id u32) {
	C.rlSetUniformSampler(loc_index, texture_id)
}

fn C.rlSetShader(id u32, locs &int)
@[inline]
pub fn rl_set_shader(id u32, locs &int) {
	C.rlSetShader(id, locs)
}

fn C.rlLoadComputeShaderProgram(shader_id u32) u32
@[inline]
pub fn rl_load_compute_shader_program(shader_id u32) u32 {
	return C.rlLoadComputeShaderProgram(shader_id)
}

fn C.rlComputeShaderDispatch(group_x u32, group_y u32, group_z u32)
@[inline]
pub fn rl_compute_shader_dispatch(group_x u32, group_y u32, group_z u32) {
	C.rlComputeShaderDispatch(group_x, group_y, group_z)
}

fn C.rlLoadShaderBuffer(size u32, data voidptr, usage_hint int) u32
@[inline]
pub fn rl_load_shader_buffer(size u32, data voidptr, usage_hint int) u32 {
	return C.rlLoadShaderBuffer(size, data, usage_hint)
}

fn C.rlUnloadShaderBuffer(ssbo_id u32)
@[inline]
pub fn rl_unload_shader_buffer(ssbo_id u32) {
	C.rlUnloadShaderBuffer(ssbo_id)
}

fn C.rlUpdateShaderBuffer(id u32, data voidptr, data_size u32, offset u32)
@[inline]
pub fn rl_update_shader_buffer(id u32, data voidptr, data_size u32, offset u32) {
	C.rlUpdateShaderBuffer(id, data, data_size, offset)
}

fn C.rlBindShaderBuffer(id u32, index u32)
@[inline]
pub fn rl_bind_shader_buffer(id u32, index u32) {
	C.rlBindShaderBuffer(id, index)
}

fn C.rlReadShaderBuffer(id u32, dest voidptr, count u32, offset u32)
@[inline]
pub fn rl_read_shader_buffer(id u32, dest voidptr, count u32, offset u32) {
	C.rlReadShaderBuffer(id, dest, count, offset)
}

fn C.rlCopyShaderBuffer(dest_id u32, src_id u32, dest_offset u32, src_offset u32, count u32)
@[inline]
pub fn rl_copy_shader_buffer(dest_id u32, src_id u32, dest_offset u32, src_offset u32, count u32) {
	C.rlCopyShaderBuffer(dest_id, src_id, dest_offset, src_offset, count)
}

fn C.rlGetShaderBufferSize(id u32) u32
@[inline]
pub fn rl_get_shader_buffer_size(id u32) u32 {
	return C.rlGetShaderBufferSize(id)
}

fn C.rlBindImageTexture(id u32, index u32, format int, readonly bool)
@[inline]
pub fn rl_bind_image_texture(id u32, index u32, format int, readonly bool) {
	C.rlBindImageTexture(id, index, format, readonly)
}

fn C.rlGetMatrixModelview() Matrix
@[inline]
pub fn rl_get_matrix_modelview() Matrix {
	return C.rlGetMatrixModelview()
}

fn C.rlGetMatrixProjection() Matrix
@[inline]
pub fn rl_get_matrix_projection() Matrix {
	return C.rlGetMatrixProjection()
}

fn C.rlGetMatrixTransform() Matrix
@[inline]
pub fn rl_get_matrix_transform() Matrix {
	return C.rlGetMatrixTransform()
}

fn C.rlGetMatrixProjectionStereo(eye int) Matrix
@[inline]
pub fn rl_get_matrix_projection_stereo(eye int) Matrix {
	return C.rlGetMatrixProjectionStereo(eye)
}

fn C.rlGetMatrixViewOffsetStereo(eye int) Matrix
@[inline]
pub fn rl_get_matrix_view_offset_stereo(eye int) Matrix {
	return C.rlGetMatrixViewOffsetStereo(eye)
}

fn C.rlSetMatrixProjection(proj Matrix)
@[inline]
pub fn rl_set_matrix_projection(proj Matrix) {
	C.rlSetMatrixProjection(proj)
}

fn C.rlSetMatrixModelview(view Matrix)
@[inline]
pub fn rl_set_matrix_modelview(view Matrix) {
	C.rlSetMatrixModelview(view)
}

fn C.rlSetMatrixProjectionStereo(right Matrix, left Matrix)
@[inline]
pub fn rl_set_matrix_projection_stereo(right Matrix, left Matrix) {
	C.rlSetMatrixProjectionStereo(right, left)
}

fn C.rlSetMatrixViewOffsetStereo(right Matrix, left Matrix)
@[inline]
pub fn rl_set_matrix_view_offset_stereo(right Matrix, left Matrix) {
	C.rlSetMatrixViewOffsetStereo(right, left)
}

fn C.rlLoadDrawCube()
@[inline]
pub fn rl_load_draw_cube() {
	C.rlLoadDrawCube()
}

fn C.rlLoadDrawQuad()
@[inline]
pub fn rl_load_draw_quad() {
	C.rlLoadDrawQuad()
}

// Compile custom shader and return shader id
//case GL_GEOMETRY_SHADER:
//case GL_GEOMETRY_SHADER:
// Load custom shader strings and return program id
// NOTE: Default attribute shader locations must be Bound before linking
// NOTE: If some attrib name is no found on the shader, it locations becomes -1
// NOTE: All uniform variables are intitialised to 0 when a program links
// Get the size of compiled shader program (not available on OpenGL ES 2.0)
// NOTE: If GL_LINK_STATUS is GL_FALSE, program binary length is zero.
//GLint binarySize = 0;
//glGetProgramiv(id, GL_PROGRAM_BINARY_LENGTH, &binarySize);
// Unload shader program
// Get shader location uniform
//if (location == -1) TRACELOG(RL_LOG_WARNING, "SHADER: [ID %i] Failed to find shader uniform: %s", shaderId, uniformName);
//else TRACELOG(RL_LOG_INFO, "SHADER: [ID %i] Shader uniform (%s) set at location: %i", shaderId, uniformName, location);
// Get shader location attribute
//if (location == -1) TRACELOG(RL_LOG_WARNING, "SHADER: [ID %i] Failed to find shader attribute: %s", shaderId, attribName);
//else TRACELOG(RL_LOG_INFO, "SHADER: [ID %i] Shader attribute (%s) set at location: %i", shaderId, attribName, location);
// Set shader value uniform
// Set shader value attribute
// Set shader value uniform matrix
// Set shader value uniform sampler
// Check if texture is already active
// Register a new active texture for the internal batch system
// NOTE: Default texture is always activated as GL_TEXTURE0
// Activate new texture unit
// Save texture id for binding on drawing
// Set shader currently active (id and locations)
// Load compute shader program
// NOTE: All uniform variables are intitialised to 0 when a program links
// Get the size of compiled shader program (not available on OpenGL ES 2.0)
// NOTE: If GL_LINK_STATUS is GL_FALSE, program binary length is zero.
//GLint binarySize = 0;
//glGetProgramiv(id, GL_PROGRAM_BINARY_LENGTH, &binarySize);
// Dispatch compute shader (equivalent to *draw* for graphics pilepine)
// Load shader storage buffer object (SSBO)
// Clear buffer data to 0
// Unload shader storage buffer object (SSBO)
// Update SSBO buffer data
// Get SSBO buffer size
// Read SSBO buffer data (GPU->CPU)
// Bind SSBO buffer
// Copy SSBO buffer data
// Bind image texture
// Matrix state management
//-----------------------------------------------------------------------------------------
// Get internal modelview matrix
// Get internal projection matrix
// Get internal accumulated transform matrix
// TODO: Consider possible transform matrices in the RLGL.State.stack
// Is this the right order? or should we start with the first stored matrix instead of the last one?
//Matrix matStackTransform = rlMatrixIdentity();
//for (int i = RLGL.State.stackCounter; i > 0; i--) matStackTransform = rlMatrixMultiply(RLGL.State.stack[i], matStackTransform);
// Get internal projection matrix for stereo render (selected eye)
// Get internal view offset matrix for stereo render (selected eye)
// Set a custom modelview matrix (replaces internal modelview matrix)
// Set a custom projection matrix (replaces internal projection matrix)
// Set eyes projection matrices for stereo rendering
// Set eyes view offsets matrices for stereo rendering
// Load and draw a quad in NDC
// Positions         Texcoords
// Gen VAO to contain VBO
// Gen and fill vertex buffer (VBO)
// Bind vertex attributes (position, texcoords)
// Positions
// Texcoords
// Draw quad
// Delete buffers (VBO and VAO)
// Load and draw a cube in NDC
// Positions          Normals               Texcoords
// Gen VAO to contain VBO
// Gen and fill vertex buffer (VBO)
// Bind vertex attributes (position, normals, texcoords)
// Positions
// Normals
// Texcoords
// Draw cube
// Delete VBO and VAO
// Get name string for pixel format
// 8 bit per pixel (no alpha)
// 8*2 bpp (2 channels)
// 16 bpp
// 24 bpp
// 16 bpp (1 bit alpha)
// 16 bpp (4 bit alpha)
// 32 bpp
// 32 bpp (1 channel - float)
// 32*3 bpp (3 channels - float)
// 32*4 bpp (4 channels - float)
// 16 bpp (1 channel - half float)
// 16*3 bpp (3 channels - half float)
// 16*4 bpp (4 channels - half float)
// 4 bpp (no alpha)
// 4 bpp (1 bit alpha)
// 8 bpp
// 8 bpp
// 4 bpp
// 4 bpp
// 8 bpp
// 4 bpp
// 4 bpp
// 8 bpp
// 2 bpp
//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------
// Load default shader (just vertex positioning and texture coloring)
// NOTE: This shader program is used for internal buffers
// NOTE: Loaded: RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs
// NOTE: All locations must be reseted to -1 (no location)
// Vertex shader directly defined, no external file required
// Precision required for OpenGL ES2 (WebGL) (on some browsers)
// Fragment shader directly defined, no external file required
// Precision required for OpenGL ES2 (WebGL)
// NOTE: Compiled vertex/fragment shaders are not deleted,
// they are kept for re-use as default shaders in case some shader loading fails
// Compile default vertex shader
// Compile default fragment shader
// Set default shader locations: attributes locations
// Set default shader locations: uniform locations
// Unload default shader
// NOTE: Unloads: RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs
// Get compressed format official GL identifier name
// GL_EXT_texture_compression_s3tc
// GL_3DFX_texture_compression_FXT1
// GL_IMG_texture_compression_pvrtc
// GL_OES_compressed_ETC1_RGB8_texture
// GL_ARB_texture_compression_rgtc
// GL_ARB_texture_compression_bptc
// GL_ARB_ES3_compatibility
// GL_KHR_texture_compression_astc_hdr
// RLGL_SHOW_GL_DETAILS_INFO
// GRAPHICS_API_OPENGL_33 || GRAPHICS_API_OPENGL_ES2
// Get pixel data size in bytes (image or texture)
// NOTE: Size depends on pixel format
// Size in bytes
// Bits per pixel
// Total data size in bytes
// Most compressed formats works on 4x4 blocks,
// if texture is smaller, minimum dataSize is 8 or 16
// Auxiliar math functions
// Get identity matrix
// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!
// RLGL_IMPLEMENTATION
