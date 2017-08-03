//
//  ARKitInternal.h
//  Spiderpig
//
//  Created by Michael Thomas on 7/26/17.
//  Copyright © 2017 Biscuit Labs, LLC. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import ARKit;

@class ARImageSensor;
@class ARMotionSensor;
@class ARDeviceOrientationSensor;
@class ARTechnique;
@class ARBuiltInLatency;
@class ARPlaneData;
@class ARPlaneEstimationTechnique;
@class ARExposureLightEstimationTechnique;
@class ARWorldAlignmentTechnique;
@class ARWorldTrackingTechnique;
@class ARCustomTechniquesSessionConfiguration;

@protocol ARTechniqueDelegate

- (void)technique:(ARTechnique * _Nonnull)technique didFailWithError:(id _Nullable)error;
- (void)technique:(ARTechnique * _Nonnull)technique didOutputResultData:(id _Nullable)outputData timestamp:(CGFloat)timestamp context:(id _Nullable)context;

@end

@interface ARTechnique

@property (nonatomic, strong, nullable) NSArray<ARTechnique *> *techniques;
@property (nonatomic, weak, nullable) id <ARTechniqueDelegate> delegate;

- (NSUInteger)requiredSensorDataTypes;

@end

@interface ARBuiltInLatency: ARTechnique
@end

@interface ARPlaneData

@property (nonatomic) NSUInteger detectionTypeMask;
@property (nonatomic) NSUInteger techniqueIdentifier;
@property (nonatomic, strong, nullable) id detectedSurfaces;

@end

@interface ARPlaneEstimationTechnique: ARTechnique
{
    NSUInteger _detectionTypeMask;
}

+ (ARPlaneData * _Nullable)detectPlanes:(NSUInteger)planes withFrame:(id _Nonnull)frame;
- (instancetype _Nullable)initWithPlaneDetection:(NSUInteger)planeDetection;

@property (nonatomic, readonly, nullable) ARCamera *camera;
@property (nonatomic, strong, nullable) ARPlaneData *planeResultData;

@end

@interface ARExposureLightEstimationTechnique: ARTechnique
@end

@interface ARWorldAlignmentTechnique: ARTechnique
@end

@interface ARWorldTrackingTechnique: ARTechnique

@property (nonatomic, strong, nullable) NSString *deviceModel;
@property (nonatomic) NSInteger latencyFrameCount;
@property (nonatomic) BOOL relocalizationEnabled;

@end

@interface ARImageSensor

@property (nonatomic, strong, nullable) AVCaptureDevice *captureDevice;
@property (nonatomic, strong, nullable) AVCaptureSession *captureSession;

@property (nonatomic) BOOL autoFocusEnabled;
@property (nonatomic) BOOL running;
@property (nonatomic) BOOL interrupted;
@property (nonatomic) NSInteger targetFramesPerSecond;

+ (id _Nullable)bestFormatForDevice:(id _Nonnull)device withResolution:(id _Nonnull)resolution pixelFormatType:(unsigned int)formatType frameRate:(CGFloat)frameRate;
+ (CGFloat)closestFrameRateIn:(id _Nonnull)thing target:(CGFloat)targetFrameRate preferHigher:(BOOL)preferHigher;

- (void)_adjustForPowerUsage;
- (void)_configureCameraExposureForDevice:(AVCaptureDevice * _Nonnull)device;
- (void)_configureCameraFocusForDevice:(AVCaptureDevice * _Nonnull)device;
- (BOOL)_validateCameraAuthorization;
- (id _Nullable)configureCaptureDevice;
- (id _Nullable)configureCaptureSession;
- (id _Nullable)delegate;
- (id _Nullable)videoOutput;
- (id _Nullable)powerUsage;
- (id _Nullable)videoResolution;

@end

#pragma mark - ARSessionConfiguration

@interface ARSessionConfiguration ()

@property (nonatomic, strong, nullable) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic) NSInteger cameraPosition;
@property (nonatomic, strong, nullable) AVCaptureSession *customCaptureSession;
@property (nonatomic, strong, nullable) NSArray *customSensors;
@property (nonatomic) NSInteger latencyFrameCount;
@property (nonatomic) NSUInteger lightEstimation;

- (NSArray<ARTechnique *> * _Nullable)techniques;

@end

@interface ARCustomTechniquesSessionConfiguration: ARSessionConfiguration

- (void)ensureTechniqueAndCustomSensorCompatibility;

@end

@interface ARWorldTrackingSessionConfiguration ()

@property (nonatomic) BOOL relocalizationEnabled;

@end

#pragma mark - ARSession

@interface ARSession ()

@property (nonatomic) NSUInteger pausedSensors;
@property (nonatomic) NSUInteger runningSensors;
@property (nonatomic) NSUInteger powerUsage;
@property (nonatomic) BOOL worldOriginInitialized;
@property (nonatomic, strong, nullable) ARWorldTrackingTechnique *worldTrackingTechnique;

- (ARTechnique * _Nullable)technique;
- (NSArray * _Nullable)availableSensors;
- (id _Nullable)_updatePowerUsage;
- (void)ARSetupInternalLogging;

@end
