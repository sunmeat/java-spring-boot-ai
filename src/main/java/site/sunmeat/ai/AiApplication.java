package site.sunmeat.ai;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.*;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.*;
import java.awt.Desktop;
import java.net.URI;
import java.util.*;

@SpringBootApplication
public class AiApplication {
    public static void main(String[] args) {
        SpringApplication.run(AiApplication.class, args);
    }
}

@Component
class BrowserLauncher {
    @EventListener(ApplicationReadyEvent.class)
    public void launchBrowser() {
        System.setProperty("java.awt.headless", "false");
        try { Desktop.getDesktop().browse(new URI("http://localhost:8080")); } catch (Exception ignored) {}
    }
}

@Service
class OpenAiService {
	// ключ взято на https://openrouter.ai/settings/keys
    @Value("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")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    // https://x.ai/api
    // https://platform.openai.com/api-keys
    // https://developer.puter.com/tutorials/free-unlimited-openai-api/ !!! FREE
    
    // private static final String API_URL = "https://api.x.ai/v1/chat/completions"; // Grok API
    // private static final String API_URL = "https://api.openai.com/v1/chat/completions"; // ChatGPT
    private static final String API_URL = "https://openrouter.ai/api/v1/chat/completions";

    public String getJoke(String topic) {
        try {
            var headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);
            headers.set("HTTP-Referer", "http://localhost:8080");
            headers.set("X-Title", "Генератор жартів");

            Map<String, Object> message = Map.of(
                "role", "user",
                "content", "Розкажи короткий смішний жарт українською мовою на тему: " + topic
            );

            Map<String, Object> requestBody = Map.of( // ліміт - 50 запитів на день, 20 на хвилину
            		// "model", "x-ai/grok-4.1-fast:free",
            	    "model", "openai/gpt-4o-mini",
            		// "model", "mistralai/mistral-7b-instruct:free",
                "messages", List.of(message),
                "temperature", 0.9, // чим вище значення, тим більше маячні
                "max_tokens", 300, // (токен ≈ 3-4 символи або 3/4 слова)
                "stream", false
            );

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.postForObject(API_URL, request, Map.class);

            if (response != null && response.containsKey("choices")) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
                if (!choices.isEmpty()) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> msg = (Map<String, Object>) choices.get(0).get("message");
                    return (String) msg.get("content");
                }
            }
            return "Не вдалося отримати жарт";
        } catch (Exception e) {
            return "Помилка AI: " + e.getMessage();
        }
    }
}

@Controller
class JokeController {
    private final OpenAiService openAiService;

    public JokeController(OpenAiService openAiService) {
        this.openAiService = openAiService;
    }

    @GetMapping("/")
    public String index() {
        return "index";
    }

    @PostMapping("/joke")
    public String getJoke(@RequestParam("topic") String topic, Model model) {
        if (topic == null || topic.trim().isEmpty()) {
            model.addAttribute("error", "Будь ласка, введіть тему!");
            return "index";
        }
        String joke = openAiService.getJoke(topic);
        model.addAttribute("topic", topic);
        model.addAttribute("joke", joke);
        return "index";
    }
}