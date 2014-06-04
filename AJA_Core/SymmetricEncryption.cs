using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Security.Cryptography;
using System.IO;
using System.Threading.Tasks;

namespace AJA_Core
{
    public static class SymmetricEncryption
    {
        #region Static Variables
        /// <summary>
        /// at least 8 chars long
        /// </summary>
        private static string salt = "w9=z4]0h";

        /// <summary>
        /// have to match the algorithm block size - for all cases can be 16 chars
        /// </summary>
        private static string iv = "fd98w7z3yupz0q41";

        private static string passPhrase = "m21!9d]%aden^poidncf";

        private static readonly Random Random = new Random();

        #endregion

        #region Private Methods

        private static byte[] GenerateSalt()
        {
            var salt = new byte[16];
            Random.NextBytes(salt);
            return salt;
        }

        private static byte[] GenerateInitializationVector(SymmetricAlgorithm algorithm)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");

            int size = algorithm.LegalBlockSizes[0].MinSize / 8;
            var iv = new byte[size];
            Random.NextBytes(iv);
            return iv;
        }

        private static void EncryptFile(SymmetricAlgorithm algorithm, string inputfilePath, string outputfilePath, string password, string salt, string iv, int? keySize = null, int passwordIterations = 1000)
        {
            EncryptFile(algorithm, inputfilePath, outputfilePath, Encoding.UTF8.GetBytes(password), Encoding.UTF8.GetBytes(salt), Encoding.UTF8.GetBytes(iv), keySize, passwordIterations);
        }

        private static void EncryptFile(SymmetricAlgorithm algorithm, string inputfilePath, string outputfile, byte[] password, byte[] salt, byte[] iv, int? keySize = null, int passwordIterations = 1000)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");
            if (String.IsNullOrEmpty(inputfilePath)) throw new ArgumentException("File path is null or empty", "filePath");
            if (!File.Exists(inputfilePath)) throw new FileNotFoundException("File does not exist", inputfilePath);
            if (password == null || password.Length == 0) throw new ArgumentException("Password is empty", "password");
            if (salt == null || salt.Length < 8) throw new ArgumentException("Salt is not at least eight bytes", "salt");
            if (iv == null || iv.Length < (algorithm.LegalBlockSizes[0].MinSize / 8)) throw new ArgumentException("Specified initialization vector (IV) does not match the block size for this algorithm", "iv");

            var fileBytes = File.ReadAllBytes(inputfilePath);
            var encryptedBytes = EncryptBytes(algorithm, fileBytes, password, salt, iv, keySize, passwordIterations);

            File.WriteAllBytes(outputfile, encryptedBytes);
        }

        private static string EncryptText(SymmetricAlgorithm algorithm, string text, string password, string salt, string iv, int? keySize = null, int passwordIterations = 1000)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");
            if (String.IsNullOrEmpty(text)) throw new ArgumentException("Text is null or empty", "text");
            if (String.IsNullOrEmpty(password)) throw new ArgumentException("Password is null or empty", "password");
            if (String.IsNullOrEmpty(salt) || salt.Length < 8) throw new ArgumentException("Salt is not at least eight bytes", "salt");
            if (String.IsNullOrEmpty(iv) || iv.Length < (algorithm.LegalBlockSizes[0].MinSize / 8)) throw new ArgumentException("Specified initialization vector (IV) does not match the block size for this algorithm", "iv");

            var encryptedBytes = EncryptBytes(algorithm, Encoding.UTF8.GetBytes(text), Encoding.UTF8.GetBytes(password), Encoding.UTF8.GetBytes(salt), Encoding.UTF8.GetBytes(iv), keySize, passwordIterations);
            return Convert.ToBase64String(encryptedBytes);
        }

        private static byte[] EncryptBytes(SymmetricAlgorithm algorithm, byte[] data, byte[] password, byte[] salt, byte[] iv, int? keySize = null, int passwordIterations = 1000)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");
            if (data == null || data.Length == 0) throw new ArgumentException("Data are empty", "data");
            if (password == null || password.Length == 0) throw new ArgumentException("Password is empty", "password");
            if (salt == null || salt.Length < 8) throw new ArgumentException("Salt is not at least eight bytes", "salt");
            if (iv == null || iv.Length < (algorithm.LegalBlockSizes[0].MinSize / 8)) throw new ArgumentException("Specified initialization vector (IV) does not match the block size for this algorithm", "iv");
            if (keySize == null) keySize = algorithm.LegalKeySizes[0].MaxSize;

            byte[] keyBytes;
            using (var rfc2898DeriveBytes = new Rfc2898DeriveBytes(password, salt, passwordIterations))
            {
                keyBytes = rfc2898DeriveBytes.GetBytes(keySize.Value / 8);
            }

            byte[] encrypted;
            using (var encryptor = algorithm.CreateEncryptor(keyBytes, iv))
            {
                using (var memoryStream = new MemoryStream())
                {
                    using (var cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write))
                    {
                        cryptoStream.Write(data, 0, data.Length);
                        cryptoStream.FlushFinalBlock();

                        encrypted = memoryStream.ToArray();

                        memoryStream.Close();
                        cryptoStream.Close();
                    }
                }
            }

            return encrypted;
        }

        private static void DecryptFile(SymmetricAlgorithm algorithm, string inputfilePath, string outputfile, string password, string salt, string iv, int? keySize = null, int passwordIterations = 1000)
        {
            DecryptFile(algorithm, inputfilePath, outputfile, Encoding.UTF8.GetBytes(password), Encoding.UTF8.GetBytes(salt), Encoding.UTF8.GetBytes(iv), keySize, passwordIterations);
        }

        private static void DecryptFile(SymmetricAlgorithm algorithm, string inputfilePath, string outputfile, byte[] password, byte[] salt, byte[] iv, int? keySize = null, int passwordIterations = 1000)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");
            if (String.IsNullOrEmpty(inputfilePath)) throw new ArgumentException("File path is null or empty", "filePath");
            if (!File.Exists(inputfilePath)) throw new FileNotFoundException("File does not exist", inputfilePath);
            if (password == null || password.Length == 0) throw new ArgumentException("Password is empty", "password");
            if (salt == null || salt.Length < 8) throw new ArgumentException("Salt is not at least eight bytes", "salt");
            if (iv == null || iv.Length < (algorithm.LegalBlockSizes[0].MinSize / 8)) throw new ArgumentException("Specified initialization vector (IV) does not match the block size for this algorithm", "iv");

            var fileBytes = File.ReadAllBytes(inputfilePath);
            var decryptedBytes = DecryptBytes(algorithm, fileBytes, password, salt, iv, keySize, passwordIterations);

            File.WriteAllBytes(outputfile, decryptedBytes);
        }

        private static string DecryptText(SymmetricAlgorithm algorithm, string encryptedText, string password, string salt, string iv, int? keySize = null, int passwordIterations = 1000)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");
            if (String.IsNullOrEmpty(encryptedText)) throw new ArgumentException("Encrypted text are empty", "encryptedText");
            if (String.IsNullOrEmpty(password)) throw new ArgumentException("Password is null or empty", "password");
            if (String.IsNullOrEmpty(salt) || salt.Length < 8) throw new ArgumentException("Salt is not at least eight bytes", "salt");
            if (String.IsNullOrEmpty(iv) || iv.Length < (algorithm.LegalBlockSizes[0].MinSize / 8)) throw new ArgumentException("Specified initialization vector (IV) does not match the block size for this algorithm", "iv");

            var decrypted = DecryptBytes(algorithm, Convert.FromBase64String(encryptedText), Encoding.UTF8.GetBytes(password), Encoding.UTF8.GetBytes(salt), Encoding.UTF8.GetBytes(iv), keySize, passwordIterations);
            return Encoding.UTF8.GetString(decrypted);
        }

        private static byte[] DecryptBytes(SymmetricAlgorithm algorithm, byte[] encryptedData, byte[] password, byte[] salt, byte[] iv, int? keySize = null, int passwordIterations = 1000)
        {
            if (algorithm == null) throw new ArgumentNullException("algorithm");
            if (encryptedData == null || encryptedData.Length == 0) throw new ArgumentException("Encrypted data is null or empty", "encryptedData");
            if (password == null || password.Length == 0) throw new ArgumentException("Password is null or empty", "password");
            if (salt == null || salt.Length < 8) throw new ArgumentException("Salt is not at least eight bytes", "salt");
            if (iv == null || iv.Length < (algorithm.LegalBlockSizes[0].MinSize / 8)) throw new ArgumentException("Specified initialization vector (IV) does not match the block size for this algorithm", "iv");
            if (keySize == null) keySize = algorithm.LegalKeySizes[0].MaxSize;

            byte[] keyBytes;
            using (var rfc2898DeriveBytes = new Rfc2898DeriveBytes(password, salt, passwordIterations))
            {
                keyBytes = rfc2898DeriveBytes.GetBytes(keySize.Value / 8);
            }

            byte[] plainTextBytes;
            int decryptedBytesCount;
            using (var decryptor = algorithm.CreateDecryptor(keyBytes, iv))
            {
                using (var memoryStream = new MemoryStream(encryptedData))
                {
                    using (var cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Read))
                    {
                        plainTextBytes = new byte[encryptedData.Length];
                        decryptedBytesCount = cryptoStream.Read(plainTextBytes, 0, plainTextBytes.Length);

                        memoryStream.Close();
                        cryptoStream.Close();
                    }
                }
            }

            return plainTextBytes.Take(decryptedBytesCount).ToArray();
        }

        #endregion

        #region File Encryption
        /// <summary>
        /// Encrypts a File using Rijndael algorithm
        /// </summary>
        /// <param name="InputFile"></param>
        /// <param name="OutputFile"></param>
        /// <param name="Password"></param>
        /// <returns></returns>
        public static string EncryptFile(string InputFile, string OutputFile)
        {
            string rtn = string.Empty;
            using (var rijndael = Rijndael.Create())
            {
                try
                {
                    EncryptFile(rijndael, InputFile, OutputFile, passPhrase, salt, iv);
                    return "Success";
                }
                catch (Exception ex) { return ex.Message; }
            }
        }
        #endregion

        #region File Decryption
        /// <summary>
        /// Decrypts a File using Rijndael algorithm
        /// </summary>
        /// <param name="InputFile"></param>
        /// <param name="OutputFile"></param>
        /// <param name="Password"></param>
        /// <returns></returns>
        public static string DecryptFile(string InputFile, string OutputFile)
        {
            string rtn = string.Empty;
            using (var rijndael = Rijndael.Create())
            {
                try
                {
                    DecryptFile(rijndael, InputFile, OutputFile, passPhrase, salt, iv);
                    return "Success";
                }
                catch (Exception ex) { return ex.Message; }
            }
        }
        #endregion

        #region String Encryption
        /// <summary>
        /// Encrypts a String using Rijndael algorithm
        /// </summary>
        /// <param name="plainText"></param>
        /// <param name="passPhrase"></param>
        /// <returns></returns>
        public static string EncryptString(string plainText)
        {
            using (var rijndael = Rijndael.Create())
            {
                return EncryptText(rijndael, plainText, passPhrase, salt, iv);
            }
        }
        #endregion

        #region String Decryption
        /// <summary>
        /// Decrypts a String using Rijndael algorithm
        /// </summary>
        /// <param name="cipherText"></param>
        /// <param name="passPhrase"></param>
        /// <returns></returns>
        public static string DecryptString(string cipherText)
        {
            using (var rijndael = Rijndael.Create())
            {
                return DecryptText(rijndael, cipherText, passPhrase, salt, iv);
            }
        }
        #endregion
    }
}
