#ifndef WORLD_H
#define WORLD_H
//engine 
#include "SoulStoneEngine/Utilities/GameCommon.hpp"
#include "SoulStoneEngine/Utilities/XMLLoaderUtilities.hpp"
#include "SoulStoneEngine/Utilities/Clock.hpp"
#include "SoulStoneEngine/Render/GraphicManager.hpp"
#include "SoulStoneEngine/Render/Skybox.hpp"
#include "SoulStoneEngine/Render/GraphicText.hpp"
#include "SoulStoneEngine/ModelSystem/Scene.hpp"
#include "SoulStoneEngine/ModelSystem/3DShapes.hpp"
#include "SoulStoneEngine/ModelSystem/IcoSphere.hpp"

class World
{
	public:
		static Camera3D*				s_camera3D;
		static FBO*						s_fbo;
		bool							m_renderWorldOriginAxes;
		float							m_zoomFactor;
		OpenGLShaderProgram*			m_fboShaderProgram;
		OpenGLShaderProgram*			m_geometryPassProgram;
		OpenGLShaderProgram*			m_animateShaderProgram;
		Scene*							m_testScene;
		IcoSphere*						m_testIcoSphere;

	private:
		RGBColor						m_mouseClickColor;
		float							m_mouseClickRadius;
		float							m_mouseClickFlashTime;

	public:
		World();
		~World();
		void Initialize();
		void InitializeGraphic();
		bool ProcessKeyDownEvent(HWND windowHandle, UINT wmMessageCode, WPARAM wParam, LPARAM lParam );
		bool ProcessMouseDownEvent(HWND windowHandle, UINT wmMessageCode, WPARAM wParam, LPARAM lParam );
		void UpdateFromKeyboard();
		void ApplyCameraTransform();
		void OpenOrCloseConsole();
		Vector2 GetMouseSinceLastChecked();
		void Update(float elapsedTime);
		void Render();
		void RenderWorldAxes();
		void DrawCursor();
		void RenderFlashCursor();
		void RenderFBOToScreen();
		void CreateLights();
		void UpdateLightsPosition( float elapsedTime );
};

extern World* theWorld;
extern WorldCoords2D g_mouseWorldPosition;
extern WorldCoords2D g_mouseScreenPosition;
extern bool g_isLeftMouseDown;
extern bool g_isRightMouseDown;
extern bool g_isHoldingShift;
extern bool g_isQuitting;
extern Matrix44 g_viewMatrix;

#endif