"""
Malaysian Employment Assistant using LOCAL LLMs via Hugging Face
No API keys required - runs completely offline!

Supports: Llama 3, Mistral, Phi-3, Gemma 2, and more
"""

import torch
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline, BitsAndBytesConfig
from typing import Dict, List, Optional
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')


# ============================================================================
# MALAYSIAN EMPLOYMENT LAW KNOWLEDGE BASE
# ============================================================================

from dataclasses import dataclass

@dataclass
class MalaysianEmploymentLaw:
    """Malaysian Employment Act 1955 guidelines"""
    MAX_HOURS_PER_DAY = 8
    MAX_HOURS_PER_WEEK = 48
    MAX_OVERTIME_PER_MONTH = 104
    MINIMUM_WAGE_MYR = 1500
    
    ANNUAL_LEAVE = {
        "less_than_2_years": 8,
        "2_to_5_years": 12,
        "more_than_5_years": 16
    }
    
    SICK_LEAVE = {
        "hospitalization": 60,
        "non_hospitalization": 14
    }
    
    PUBLIC_HOLIDAYS_MIN = 11
    EPF_EMPLOYEE_RATE = 0.11
    EPF_EMPLOYER_RATE = 0.13


class MalaysianLivingExpenses:
    """Average living expenses in Malaysia"""
    EXPENSES = {
        "kuala_lumpur": {
            "rent_1br": {"min": 1200, "max": 2500},
            "utilities": {"min": 150, "max": 300},
            "food": {"min": 600, "max": 1200},
            "transport": {"min": 200, "max": 500},
            "healthcare": {"min": 100, "max": 300},
            "entertainment": {"min": 200, "max": 500}
        },
        "penang": {
            "rent_1br": {"min": 800, "max": 1800},
            "utilities": {"min": 120, "max": 250},
            "food": {"min": 500, "max": 1000},
            "transport": {"min": 150, "max": 400},
            "healthcare": {"min": 80, "max": 250},
            "entertainment": {"min": 150, "max": 400}
        },
        "johor_bahru": {
            "rent_1br": {"min": 700, "max": 1500},
            "utilities": {"min": 120, "max": 250},
            "food": {"min": 450, "max": 900},
            "transport": {"min": 150, "max": 350},
            "healthcare": {"min": 80, "max": 250},
            "entertainment": {"min": 150, "max": 350}
        }
    }


# ============================================================================
# LOCAL LLM WRAPPER - HUGGING FACE
# ============================================================================

class LocalLLM:
    """
    Wrapper for local LLM models from Hugging Face
    
    Recommended Models (sorted by size/performance):
    
    Small (Fast, lower memory):
    - "microsoft/Phi-3-mini-4k-instruct" (3.8B) - Great balance!
    - "TinyLlama/TinyLlama-1.1B-Chat-v1.0" (1.1B) - Very fast
    
    Medium (Good quality):
    - "mistralai/Mistral-7B-Instruct-v0.3" (7B)
    - "google/gemma-2-9b-it" (9B)
    
    Large (Best quality, needs GPU):
    - "meta-llama/Meta-Llama-3-8B-Instruct" (8B)
    - "meta-llama/Meta-Llama-3.1-8B-Instruct" (8B)
    """
    
    def __init__(self, 
                 model_name="microsoft/Phi-3-mini-4k-instruct",
                 device=None,
                 load_in_4bit=False,
                 load_in_8bit=False):
        """
        Initialize local LLM
        
        Args:
            model_name: HuggingFace model identifier
            device: 'cuda', 'cpu', or None (auto-detect)
            load_in_4bit: Use 4-bit quantization (saves memory)
            load_in_8bit: Use 8-bit quantization
        """
        self.model_name = model_name
        
        # Auto-detect device
        if device is None:
            device = "cuda" if torch.cuda.is_available() else "cpu"
        
        self.device = device
        print(f"🔧 Device: {device}")
        
        if device == "cuda":
            print(f"🎮 GPU: {torch.cuda.get_device_name(0)}")
            print(f"💾 GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.2f} GB")
        
        print(f"🔄 Loading model: {model_name}")
        print("⏳ This may take a few minutes on first run...")
        
        # Configure quantization if needed
        quantization_config = None
        if load_in_4bit:
            quantization_config = BitsAndBytesConfig(
                load_in_4bit=True,
                bnb_4bit_compute_dtype=torch.float16,
                bnb_4bit_use_double_quant=True,
                bnb_4bit_quant_type="nf4"
            )
            print("🔧 Using 4-bit quantization")
        elif load_in_8bit:
            quantization_config = BitsAndBytesConfig(load_in_8bit=True)
            print("🔧 Using 8-bit quantization")
        
        # Load tokenizer
        self.tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            trust_remote_code=True
        )
        
        # Set pad token if not exists
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
        
        # Load model
        model_kwargs = {
            "trust_remote_code": True,
            "torch_dtype": torch.float16 if device == "cuda" else torch.float32,
        }
        
        if quantization_config:
            model_kwargs["quantization_config"] = quantization_config
            model_kwargs["device_map"] = "auto"
        
        self.model = AutoModelForCausalLM.from_pretrained(
            model_name,
            **model_kwargs
        )
        
        # Move to device if not using quantization
        if not quantization_config and device == "cpu":
            self.model = self.model.to(device)
        
        # Create pipeline
        self.pipe = pipeline(
            "text-generation",
            model=self.model,
            tokenizer=self.tokenizer,
            device=0 if device == "cuda" else -1,
            max_new_tokens=1024,
            do_sample=True,
            temperature=0.7,
            top_p=0.95,
            repetition_penalty=1.15
        )
        
        print("✅ Model loaded successfully!\n")
    
    def generate(self, prompt: str, max_tokens=512) -> str:
        """Generate text from prompt"""
        try:
            result = self.pipe(
                prompt,
                max_new_tokens=max_tokens,
                do_sample=True,
                temperature=0.7,
                top_p=0.95,
                return_full_text=False
            )
            return result[0]["generated_text"].strip()
        except Exception as e:
            return f"Error generating response: {e}"
    
    def chat(self, message: str, system_prompt: str = None) -> str:
        """
        Chat interface with proper formatting for different models
        """
        # Format based on model type
        if "llama-3" in self.model_name.lower() or "llama3" in self.model_name.lower():
            # Llama 3 format
            prompt = f"<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n"
            if system_prompt:
                prompt += f"{system_prompt}<|eot_id|>"
            prompt += f"<|start_header_id|>user<|end_header_id|>\n\n{message}<|eot_id|>"
            prompt += f"<|start_header_id|>assistant<|end_header_id|>\n\n"
        
        elif "phi-3" in self.model_name.lower():
            # Phi-3 format
            prompt = "<|system|>\n"
            if system_prompt:
                prompt += f"{system_prompt}\n"
            prompt += f"<|end|>\n<|user|>\n{message}<|end|>\n<|assistant|>\n"
        
        elif "mistral" in self.model_name.lower():
            # Mistral format
            prompt = "<s>"
            if system_prompt:
                prompt += f"[INST] {system_prompt}\n\n{message} [/INST]"
            else:
                prompt += f"[INST] {message} [/INST]"
        
        elif "gemma" in self.model_name.lower():
            # Gemma format
            prompt = "<start_of_turn>user\n"
            if system_prompt:
                prompt += f"{system_prompt}\n\n"
            prompt += f"{message}<end_of_turn>\n<start_of_turn>model\n"
        
        else:
            # Generic format
            if system_prompt:
                prompt = f"System: {system_prompt}\n\nUser: {message}\n\nAssistant:"
            else:
                prompt = f"User: {message}\n\nAssistant:"
        
        return self.generate(prompt, max_tokens=1024)


# ============================================================================
# MALAYSIAN EMPLOYMENT ASSISTANT - LOCAL VERSION
# ============================================================================

class LocalMalaysianAssistant:
    """Malaysian Employment Assistant using local LLM"""
    
    def __init__(self, 
                 model_name="microsoft/Phi-3-mini-4k-instruct",
                 device=None,
                 use_quantization=False):
        """
        Initialize assistant with local LLM
        
        Recommended models:
        - "microsoft/Phi-3-mini-4k-instruct" - Best balance (3.8B)
        - "TinyLlama/TinyLlama-1.1B-Chat-v1.0" - Fastest (1.1B)
        - "mistralai/Mistral-7B-Instruct-v0.3" - Better quality (7B)
        - "meta-llama/Meta-Llama-3-8B-Instruct" - Best quality (8B, needs GPU)
        """
        
        print("🇲🇾 Initializing Malaysian Employment Assistant")
        print("=" * 60)
        
        # Initialize LLM
        self.llm = LocalLLM(
            model_name=model_name,
            device=device,
            load_in_4bit=use_quantization
        )
        
        # Initialize knowledge bases
        self.employment_law = MalaysianEmploymentLaw()
        self.expenses = MalaysianLivingExpenses()
        
        # System prompt
        self.system_prompt = """You are an expert Malaysian employment law assistant.

You have deep knowledge of:
- Employment Act 1955 (Malaysia)
- Malaysian labor rights and employee protection
- EPF (Employees Provident Fund) and SOCSO contributions
- Malaysian workplace culture and professional communication
- Cost of living and financial planning in Malaysia

Key Malaysian Employment Law Facts:
- Maximum working hours: 8 hours/day, 48 hours/week
- Minimum wage: RM 1,500/month (as of 2024)
- Overtime rate: 1.5x for normal days, 2x for rest days, 3x for public holidays
- Annual leave: 8-16 days depending on service length
- Sick leave: 14 days outpatient, 60 days hospitalization
- Maternity leave: 98 days (14 weeks)
- EPF contribution: 11% employee, 13% employer

Provide accurate, helpful advice while being culturally sensitive to Malaysian workplace dynamics.
Always be professional, supportive, and cite relevant laws when applicable."""
    
    # ========================================================================
    # UTILITY FUNCTIONS
    # ========================================================================
    
    def check_working_hours(self, hours_per_week: float) -> str:
        """Check if working hours comply with Malaysian law"""
        law = self.employment_law
        
        if hours_per_week <= law.MAX_HOURS_PER_WEEK:
            return f"✅ Your working hours ({hours_per_week} hrs/week) comply with Malaysian Employment Act (max {law.MAX_HOURS_PER_WEEK} hrs/week)."
        else:
            overtime = hours_per_week - law.MAX_HOURS_PER_WEEK
            return f"""⚠️ Your working hours ({hours_per_week} hrs/week) EXCEED the legal limit of {law.MAX_HOURS_PER_WEEK} hrs/week.

Overtime: {overtime} hours/week
Legal rights:
- Overtime must be paid at 1.5x your hourly rate
- Maximum overtime: {law.MAX_OVERTIME_PER_MONTH} hours/month
- You have the right to refuse excessive overtime

Recommendation: Discuss with your employer about compliance with Employment Act 1955."""
    
    def calculate_salary_breakdown(self, gross_salary: float) -> str:
        """Calculate salary breakdown with EPF, SOCSO, and EIS"""
        law = self.employment_law
        
        # EPF Contributions
        epf_employee = gross_salary * law.EPF_EMPLOYEE_RATE
        epf_employer = gross_salary * law.EPF_EMPLOYER_RATE
        
        # SOCSO (simplified)
        if gross_salary <= 5000:
            socso_employee = min(gross_salary * 0.005, 24.75)
            socso_employer = min(gross_salary * 0.018, 89.25)
        else:
            socso_employee = 24.75
            socso_employer = 89.25
        
        # EIS (Employment Insurance System)
        eis_employee = min(gross_salary * 0.002, 7.90)
        eis_employer = min(gross_salary * 0.002, 7.90)
        
        # Calculate net pay
        total_deductions = epf_employee + socso_employee + eis_employee
        net_pay = gross_salary - total_deductions
        
        return f"""💰 Salary Breakdown for RM {gross_salary:,.2f}

Employee Deductions:
- EPF (11%): RM {epf_employee:,.2f}
- SOCSO: RM {socso_employee:,.2f}
- EIS: RM {eis_employee:,.2f}
- Total Deductions: RM {total_deductions:,.2f}

💵 Your Net Pay: RM {net_pay:,.2f}

Employer Contributions:
- EPF (13%): RM {epf_employer:,.2f}
- SOCSO: RM {socso_employer:,.2f}
- EIS: RM {eis_employer:,.2f}
- Total: RM {epf_employer + socso_employer + eis_employer:,.2f}"""
    
    def calculate_expense_budget(self, city: str, salary: float) -> str:
        """Calculate living expenses budget"""
        city_key = city.lower().replace(" ", "_")
        
        if city_key not in self.expenses.EXPENSES:
            city_key = "kuala_lumpur"
        
        expenses = self.expenses.EXPENSES[city_key]
        
        total_min = sum(cat["min"] for cat in expenses.values())
        total_max = sum(cat["max"] for cat in expenses.values())
        total_avg = (total_min + total_max) / 2
        
        savings = salary - total_avg
        savings_rate = (savings / salary * 100) if salary > 0 else 0
        
        return f"""🏙️ Living Expenses Budget for {city.title()}

Monthly Expenses (RM):
- Rent (1BR): {expenses['rent_1br']['min']} - {expenses['rent_1br']['max']}
- Utilities: {expenses['utilities']['min']} - {expenses['utilities']['max']}
- Food: {expenses['food']['min']} - {expenses['food']['max']}
- Transport: {expenses['transport']['min']} - {expenses['transport']['max']}
- Healthcare: {expenses['healthcare']['min']} - {expenses['healthcare']['max']}
- Entertainment: {expenses['entertainment']['min']} - {expenses['entertainment']['max']}

Total Range: RM {total_min:,.2f} - RM {total_max:,.2f}
Average: RM {total_avg:,.2f}

Your Salary: RM {salary:,.2f}
Estimated Savings: RM {savings:,.2f} ({savings_rate:.1f}%)

💡 Financial Health: {"✅ Good" if savings_rate >= 20 else "⚠️ Consider budgeting" if savings_rate >= 10 else "❌ Tight budget"}"""
    
    def get_employment_rights(self) -> str:
        """Get Malaysian employment rights information"""
        law = self.employment_law
        
        return f"""📋 Malaysian Employment Rights (Employment Act 1955)

Working Hours:
- Standard: {law.MAX_HOURS_PER_DAY} hours/day, {law.MAX_HOURS_PER_WEEK} hours/week
- Overtime: Max {law.MAX_OVERTIME_PER_MONTH} hours/month
- Rest days: 1 day per week (minimum)

Minimum Wage:
- RM {law.MINIMUM_WAGE_MYR}/month (as of 2024)

Leave Entitlements:
- Annual Leave: {law.ANNUAL_LEAVE['less_than_2_years']}-{law.ANNUAL_LEAVE['more_than_5_years']} days (based on service)
- Sick Leave: {law.SICK_LEAVE['non_hospitalization']} days outpatient, {law.SICK_LEAVE['hospitalization']} days hospitalization
- Public Holidays: Minimum {law.PUBLIC_HOLIDAYS_MIN} days
- Maternity Leave: 98 days (14 weeks)

Termination Rights:
- Notice period required (varies by service length)
- Severance pay for retrenchment
- Protection against unfair dismissal

How to Deal with Boss Issues:
1. Document everything (emails, messages, incidents)
2. Know your employment contract terms
3. Communicate professionally and in writing
4. Escalate to HR if direct communication fails
5. Contact Department of Labour for violations
6. Consider Industrial Relations Department for disputes

Resources:
- Department of Labour: 1-300-80-8000
- Employment Act 1955 compliance queries"""
    
    # ========================================================================
    # MAIN CHAT INTERFACE
    # ========================================================================
    
    def chat(self, message: str) -> str:
        """Main chat interface"""
        print(f"\n💬 You: {message}")
        print(f"🤖 Thinking...")
        
        response = self.llm.chat(message, self.system_prompt)
        
        print(f"🤖 Assistant: {response}\n")
        return response
    
    def ask_about_working_hours(self, hours: float) -> str:
        """Specific query about working hours"""
        context = self.check_working_hours(hours)
        
        prompt = f"""{context}

User is working {hours} hours per week in Malaysia. 

Provide professional advice on:
1. Whether this complies with Malaysian Employment Act 1955
2. What actions they can take if it's excessive
3. How to professionally discuss this with their employer
4. Their legal rights regarding overtime pay"""
        
        return self.chat(prompt)
    
    def ask_about_salary(self, salary: float) -> str:
        """Specific query about salary"""
        breakdown = self.calculate_salary_breakdown(salary)
        
        prompt = f"""{breakdown}

Provide analysis for this RM {salary} salary in Malaysia:
1. Is this above minimum wage?
2. Is this competitive in the Malaysian job market?
3. Financial planning advice
4. How to professionally negotiate for better pay"""
        
        return self.chat(prompt)
    
    def ask_about_boss_issue(self, issue: str) -> str:
        """Get advice on dealing with boss issues"""
        prompt = f"""A Malaysian employee needs advice on this workplace issue:

{issue}

Provide professional guidance on:
1. Assessment under Malaysian Employment Act 1955
2. Professional and diplomatic approach to address it
3. Escalation steps if needed (HR, Department of Labour)
4. Legal rights and protections
5. Cultural considerations for Malaysian workplace

Be supportive, practical, and cite relevant laws."""
        
        return self.chat(prompt)
    
    def ask_about_expenses(self, city: str, salary: float) -> str:
        """Ask about living expenses"""
        budget = self.calculate_expense_budget(city, salary)
        
        prompt = f"""{budget}

Provide financial advice for living in {city} with RM {salary} salary:
1. Is this salary sufficient?
2. Budgeting tips for Malaysian context
3. Ways to increase savings
4. Cost-saving strategies"""
        
        return self.chat(prompt)


# ============================================================================
# INTERACTIVE MENU
# ============================================================================

def print_menu():
    """Print interactive menu"""
    print("\n" + "=" * 60)
    print("🇲🇾 MALAYSIAN EMPLOYMENT ASSISTANT")
    print("=" * 60)
    print("\n📋 Main Menu:")
    print("  1. Check working hours compliance")
    print("  2. Calculate salary breakdown")
    print("  3. Calculate living expenses budget")
    print("  4. Get employment rights information")
    print("  5. Ask about dealing with boss/employer")
    print("  6. Free chat with assistant")
    print("  7. Exit")
    print()


def main():
    """Main interactive application"""
    
    print("\n🚀 Starting Malaysian Employment Assistant")
    print("=" * 60)
    
    # Model selection
    print("\n📦 Available Models:")
    print("  1. Phi-3 Mini (3.8B) - Recommended, fast & good quality")
    print("  2. TinyLlama (1.1B) - Fastest, lower quality")
    print("  3. Mistral 7B (7B) - Better quality, needs more RAM")
    print("  4. Llama 3 8B (8B) - Best quality, needs GPU")
    
    model_choice = input("\nSelect model (1-4, default=1): ").strip() or "1"
    
    models = {
        "1": "microsoft/Phi-3-mini-4k-instruct",
        "2": "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
        "3": "mistralai/Mistral-7B-Instruct-v0.3",
        "4": "meta-llama/Meta-Llama-3-8B-Instruct"
    }
    
    selected_model = models.get(model_choice, models["1"])
    
    # Ask about quantization
    use_quant = input("\n💾 Use 4-bit quantization to save memory? (y/n, default=n): ").strip().lower() == 'y'
    
    # Initialize assistant
    try:
        assistant = LocalMalaysianAssistant(
            model_name=selected_model,
            use_quantization=use_quant
        )
    except Exception as e:
        print(f"\n❌ Error loading model: {e}")
        print("\n💡 Tip: If you see an error, try:")
        print("   - Using quantization (answer 'y' above)")
        print("   - Selecting a smaller model (option 1 or 2)")
        print("   - Making sure you have enough RAM/VRAM")
        return
    
    # Main loop
    while True:
        print_menu()
        choice = input("👉 Select option (1-7): ").strip()
        
        if choice == "1":
            hours = float(input("\n⏰ Enter hours worked per week: "))
            assistant.ask_about_working_hours(hours)
        
        elif choice == "2":
            salary = float(input("\n💰 Enter gross salary (RM): "))
            assistant.ask_about_salary(salary)
        
        elif choice == "3":
            print("\n🏙️ Cities: Kuala Lumpur, Penang, Johor Bahru")
            city = input("Enter city: ").strip() or "Kuala Lumpur"
            salary = float(input("Enter your salary (RM): "))
            assistant.ask_about_expenses(city, salary)
        
        elif choice == "4":
            print("\n" + assistant.get_employment_rights())
        
        elif choice == "5":
            print("\n📝 Describe your issue with your boss/employer:")
            issue = input("Issue: ").strip()
            if issue:
                assistant.ask_about_boss_issue(issue)
        
        elif choice == "6":
            print("\n💬 Free Chat Mode (type 'back' to return to menu)")
            while True:
                user_input = input("\nYou: ").strip()
                if user_input.lower() in ['back', 'menu', 'exit']:
                    break
                if user_input:
                    assistant.chat(user_input)
        
        elif choice == "7":
            print("\n👋 Thank you for using Malaysian Employment Assistant!")
            print("Stay informed about your rights! 🇲🇾")
            break
        
        else:
            print("\n❌ Invalid choice, please try again")
        
        input("\nPress Enter to continue...")


if __name__ == "__main__":
    main()