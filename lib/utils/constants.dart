class AppConstants {
  static const String appName = 'Virtual Try-On';
  // Replace with your Hugging Face API Token
  static const String hfApiToken = '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';

  // Example Model URL (yisol/IDM-VTON is popular, but might require a dedicated Space or endpoint)
  // We will assume a standard Inference Endpoint or a Space run via API.
  // For this example, I'll use a placeholder URL that the user should replace with their working VTON endpoint.
  // Many users use Replicate or a specific HF Space for VTON as the generic Inference API often times out for high-compute tasks.
  static const String modelApiUrl =
      'https://api-inference.huggingface.co/models/yisol/IDM-VTON';
}
