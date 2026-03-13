class AppConstants {
  static const String appName = 'Virtual Try-On';
  // Replace with your Hugging Face API Token
  static const String hfApiToken = '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';

  // Example Model URL (yisol/IDM-VTON is popular, but might require a dedicated Space or endpoint)
  // We will assume a standard Inference Endpoint or a Space run via API.
  // For this example, I'll use a placeholder URL that the user should replace with their working VTON endpoint.
  // Many users use Replicate or a specific HF Space for VTON as the generic Inference API often times out for high-compute tasks.
  // We will use the direct Space API because the serverless Inference API (api-inference...)
  // often returns 503 or 410 for this heavy model.
  static const String modelApiUrl =
      'https://yisol-idm-vton.hf.space/api/predict';
}
